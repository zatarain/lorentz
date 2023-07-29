resource "aws_ecr_repository" "image" {
  name = var.name
}

resource "aws_ecs_cluster" "portfolio" {
  name = var.name
}

locals {
  api_container = "${var.prefix}-api-run"
  web_container = "${var.prefix}-web-run"
  postgres_user = one(aws_db_instance.postgres.master_user_secret)
}

data "template_file" "back-end-task-definition" {
  template = file("${path.module}/task-definition.json.tpl")
  vars = {
    CONTAINER = local.api_container
    IMAGE     = replace(aws_ecr_repository.image.repository_url, "https://", "")
    TAG       = "back-end"
    PORT      = 3000
    ENVIRONMENT = jsonencode([
      {
        name  = "AWS_ENVIRONMENT"
        value = terraform.workspace
      },
			{
				name  = "AWS_REGION"
				value = "eu-west-1"
			},
			{
				name  = "RAILS_ENV"
				value = "production"
			},
      {
        name  = "INSTAGRAM_REDIRECT_URI"
        value = "https://${var.domain}"
      },
      {
        name  = "POSTGRES_HOST"
        value = aws_db_instance.postgres.address
      },
      {
        name  = "POSTGRES_PORT"
        value = tostring(aws_db_instance.postgres.port)
      },
    ])
    SECRETS = jsonencode([
      {
        name  = "INSTAGRAM_CLIENT_ID"
        valueFrom = "${aws_secretsmanager_secret.instagram.arn}:id::"
      },
      {
        name  = "INSTAGRAM_CLIENT_SECRET"
        valueFrom = "${aws_secretsmanager_secret.instagram.arn}:key::"
      },
      {
        name  = "INSTAGRAM_ACCESS_TOKEN"
        valueFrom = "${aws_secretsmanager_secret.instagram.arn}:token::"
      },
      {
        name  = "POSTGRES_USERNAME"
        valueFrom = "${local.postgres_user.secret_arn}:username::"
      },
      {
        name  = "POSTGRES_PASSWORD"
        valueFrom = "${local.postgres_user.secret_arn}:password::"
      },
    ])
  }
}

resource "aws_ecs_task_definition" "api-run" {
  family                   = local.api_container # Naming our first task
  container_definitions    = data.template_file.back-end-task-definition.rendered
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 2048        # Specifying the memory our container requires
  cpu                      = 1024        # Specifying the CPU our container requires
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

data "aws_iam_policy_document" "secrets-manager-access" {
  statement {
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      aws_secretsmanager_secret.instagram.arn,
      local.postgres_user.secret_arn,
    ]
  }
}

resource "aws_iam_policy" "secrets-access" {
  name   = "PortfolioSecretsAccess"
  path   = "/"
  policy = data.aws_iam_policy_document.secrets-manager-access.json
}

resource "aws_iam_role_policy_attachment" "task-command-executor-policy" {
  role       = aws_iam_role.task-command-executor.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "task-executor-access-to-s3" {
  role       = aws_iam_role.task-command-executor.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "task-executor-access-to-secrets" {
  role       = aws_iam_role.task-runner.name
  policy_arn = aws_iam_policy.secrets-access.arn
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
    target_group_arn = aws_alb_target_group.back-end.arn
    container_name   = aws_ecs_task_definition.api-run.family
    container_port   = 3000
  }

  network_configuration {
    assign_public_ip = true
    subnets          = [var.subnet]

    security_groups = [
      aws_security_group.alb-access.id,
    ]
  }
}

data "template_file" "front-end-task-definition" {
  template = file("${path.module}/task-definition.json.tpl")
  vars = {
    CONTAINER = local.web_container
    IMAGE     = replace(aws_ecr_repository.image.repository_url, "https://", "")
    TAG       = "front-end"
    PORT      = 5000
    ENVIRONMENT = jsonencode([
      {
        name = "AWS_ENVIRONMENT"
        value = terraform.workspace
      },
			{
				name= "API_URL",
				value= "https://api.${var.domain}"
			},
			{
				name= "NODE_ENV",
				value= "production"
			},
    ])
    SECRETS = jsonencode([])
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
    target_group_arn = aws_alb_target_group.front-end.arn
    container_name   = aws_ecs_task_definition.web-run.family
    container_port   = 5000
  }

  network_configuration {
    assign_public_ip = true
    subnets          = [var.subnet]

    security_groups = [
      aws_security_group.alb-access.id,
    ]
  }
}
