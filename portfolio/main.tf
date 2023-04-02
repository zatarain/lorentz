resource "aws_ecs_cluster" "portfolio" {
  name = var.name
}

resource "aws_ecr_repository" "hub" {
  name = var.repository
}

data "template_file" "task-definition-template" {
  template = file("${path.module}/task-definition.json.tpl")
  vars = {
    IMAGENAME = replace(aws_ecr_repository.hub.repository_url, "https://", "")
  }
}

resource "aws_ecs_task_definition" "api-run" {
  family                   = "${var.prefix}-api-run" # Naming our first task
  container_definitions    = data.template_file.task-definition-template.rendered
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.task-runner.arn
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

resource "aws_ecs_service" "api" {
  name            = "${var.prefix}-api"                 # Naming our first service
  cluster         = aws_ecs_cluster.portfolio.id        # Referencing our created Cluster
  task_definition = aws_ecs_task_definition.api-run.arn # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 2 # Number of deployed containers
}
