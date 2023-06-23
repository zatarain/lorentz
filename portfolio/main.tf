resource "aws_ecr_repository" "image" {
  name = var.name
}

resource "aws_ecs_cluster" "portfolio" {
  name = var.name
}

locals {
  api_container = "${var.prefix}-api-run"
  web_container = "${var.prefix}-web-run"
}

data "template_file" "back-end-task-definition" {
  template = file("${path.module}/task-definition.json.tpl")
  vars = {
    CONTAINER = local.api_container
    IMAGE     = replace(aws_ecr_repository.image.repository_url, "https://", "")
    TAG       = "back-end"
    PORT      = 3000
    API_URL   = "https://api.${var.domain}"
    CONTROL   = "RAILS_ENV"
  }
}

resource "aws_ecs_task_definition" "api-run" {
  family                   = local.api_container # Naming our first task
  container_definitions    = data.template_file.back-end-task-definition.rendered
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.task-runner.arn
  task_role_arn            = aws_iam_role.task-command-executor.arn
}

resource "aws_iam_role" "task-runner" {
  name               = "${var.prefix}-task-runner"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task-runner-policy" {
  role       = aws_iam_role.task-runner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task-command-executor" {
  name               = "${var.prefix}-task-command-executor"
  assume_role_policy = data.aws_iam_policy_document.command-executor.json
}

data "aws_iam_policy_document" "command-executor" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task-command-executor-policy" {
  role       = aws_iam_role.task-command-executor.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_ecs_service" "api" {
  name    = "${var.prefix}-api"
  cluster = aws_ecs_cluster.portfolio.id

  # Referencing the task our service will spin up
  task_definition        = aws_ecs_task_definition.api-run.arn
  launch_type            = "FARGATE"
  enable_execute_command = true
  desired_count          = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.back-end-workers.arn
    container_name   = aws_ecs_task_definition.api-run.family
    container_port   = 3000
  }

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets

    security_groups = [
      aws_security_group.api-access.id,
    ]
  }
}

resource "aws_security_group" "api-access" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # Only allowing traffic in from the load balancer security group
    security_groups = [
      aws_security_group.back-end-entry-point.id,
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

data "template_file" "front-end-task-definition" {
  template = file("${path.module}/task-definition.json.tpl")
  vars = {
    CONTAINER = local.web_container
    IMAGE     = replace(aws_ecr_repository.image.repository_url, "https://", "")
    TAG       = "front-end"
    PORT      = 5000
    API_URL   = "https://api.${var.domain}"
    CONTROL   = "NODE_ENV"

  }
}

resource "aws_ecs_task_definition" "web-run" {
  family                   = local.web_container # Naming our first task
  container_definitions    = data.template_file.front-end-task-definition.rendered
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.task-runner.arn
  task_role_arn            = aws_iam_role.task-command-executor.arn
}

resource "aws_ecs_service" "web" {
  name    = "${var.prefix}-web"
  cluster = aws_ecs_cluster.portfolio.id

  # Referencing the task our service will spin up
  task_definition        = aws_ecs_task_definition.web-run.arn
  launch_type            = "FARGATE"
  enable_execute_command = true
  desired_count          = 2

  load_balancer {
    target_group_arn = aws_lb_target_group.front-end-workers.arn
    container_name   = aws_ecs_task_definition.web-run.family
    container_port   = 5000
  }

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets

    security_groups = [
      aws_security_group.web-access.id,
    ]
  }
}

resource "aws_security_group" "web-access" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # Only allowing traffic in from the load balancer security group
    security_groups = [
      aws_security_group.front-end-entry-point.id,
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
