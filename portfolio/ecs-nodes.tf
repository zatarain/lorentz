data "aws_iam_policy_document" "ecs_node_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs-node" {
  name_prefix        = "demo-ecs-node-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_node_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs-node-role-policy" {
  role       = aws_iam_role.ecs-node.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs-node" {
  name_prefix = "ecs-node"
  path        = "/ecs/instance/"
  role        = aws_iam_role.ecs-node.name
}

# --- ECS Launch Template ---

data "aws_ssm_parameter" "ecs-image" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs-instance" {
  name_prefix            = "ecs-instance-"
  image_id               = data.aws_ssm_parameter.ecs-image.value
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.node-output.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ecs-node.arn
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

# --- ECS ASG ---

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

# --- ECS Capacity Provider ---

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
