data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_configuration" "ecs" {
	image_id             = "ami-01dd271720c1ba44f" # data.aws_ami.ecs.image_id
	iam_instance_profile = aws_iam_instance_profile.ecs-task-runner.name
	security_groups      = [var.alb-group.id]
	user_data            = "#!/bin/bash\necho ECS_CLUSTER=${var.name} >> /etc/ecs/ecs.config"
	instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
	name                      = var.name
	vpc_zone_identifier       = var.subnets
	launch_configuration      = aws_launch_configuration.ecs.name
	desired_capacity          = 2
	min_size                  = 1
	max_size                  = 10
	health_check_grace_period = 300
	health_check_type         = "EC2"
}
