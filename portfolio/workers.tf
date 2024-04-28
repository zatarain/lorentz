resource "aws_iam_instance_profile" "ecs-worker" {
  name_prefix = "ecs-worker"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs-worker.name
}

data "aws_ssm_parameter" "ecs-image" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

/**
resource "aws_launch_template" "ecs-instance" {
  name_prefix            = "ecs-instance-"
  image_id               = data.aws_ssm_parameter.ecs-image.value
  instance_type          = "t3.small"
  vpc_security_group_ids = [var.alb-access.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs-worker.arn
  }

  metadata_options {
    http_protocol_ipv6 = "disabled"
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<-EOF
      #!/bin/bash
      echo ECS_CLUSTER=${aws_ecs_cluster.portfolio.name} >> /etc/ecs/ecs.config
    EOF
  )
}

/**
resource "aws_autoscaling_group" "cluster" {
  name_prefix               = "${var.name}-"
  vpc_zone_identifier       = var.subnets
  min_size                  = 1
  max_size                  = 3
  health_check_grace_period = 0
  health_check_type         = "EC2"
  protect_from_scale_in     = false

  launch_template {
    id      = aws_launch_template.ecs-instance.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-cluster"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "portfolio" {
  name = var.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.cluster.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "portfolio" {
  cluster_name       = aws_ecs_cluster.portfolio.name
  capacity_providers = [aws_ecs_capacity_provider.portfolio.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.portfolio.name
    base              = 1
    weight            = 100
  }
}
/**/
