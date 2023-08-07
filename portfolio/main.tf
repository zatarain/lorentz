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

data "template_file" "api" {
  template = file("${path.module}/container-definition.json.tpl")
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

data "template_file" "web" {
  template = file("${path.module}/container-definition.json.tpl")
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

data "template_file" "task-definition" {
  template = file("${path.module}/task-definition.json.tpl")
  vars = {
    SERVICE = data.template_file.api.rendered
    WEBSITE = data.template_file.web.rendered
  }
}

resource "aws_ecs_task_definition" "website-run" {
  family                   = var.name    # Naming our task
  container_definitions    = data.template_file.task-definition.rendered
  # requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  # memory                   = 2048        # Specifying the memory our swarm requires
  # cpu                      = 1024        # Specifying the CPU our swarm requires
  execution_role_arn       = aws_iam_role.task-runner.arn
  task_role_arn            = aws_iam_role.task-command-executor.arn
}

resource "aws_ecs_service" "website" {
  name    = "${var.prefix}-website"
  cluster = aws_ecs_cluster.portfolio.id

  # Referencing the task our service will spin up
  task_definition        = aws_ecs_task_definition.website-run.arn
  launch_type            = "EC2"
  # enable_execute_command = true
  desired_count          = 2

  load_balancer {
    target_group_arn = aws_alb_target_group.back-end.arn
    container_name   = local.api_container
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.front-end.arn
    container_name   = local.web_container
    container_port   = 5000
  }

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets

    security_groups = [
      var.alb-access.id,
    ]
  }
}
