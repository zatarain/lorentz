resource "aws_ecs_cluster" "portfolio" {
  name = var.name
}

resource "aws_cloudwatch_log_group" "portfolio" {
  name              = "/ecs/portfolio"
  retention_in_days = 1
}

/**/
resource "aws_ecs_service" "website" {
  name    = "${var.prefix}-website"
  cluster = aws_ecs_cluster.portfolio.id

  # Referencing the task our service will spin up
  task_definition        = aws_ecs_task_definition.website-run.arn
  enable_execute_command = true
  desired_count          = 1

  # Prevent premature shutdown
  health_check_grace_period_seconds = 300

  # Capacity and Life cycle
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.portfolio.name
    base              = 1
    weight            = 100
  }

  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  # Network and Load Balancer
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
    subnets          = var.subnets

    security_groups = [
      var.alb-access.id,
    ]
  }
}
/**/
