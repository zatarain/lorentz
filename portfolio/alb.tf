resource "aws_alb" "back-end" {
  name               = "${var.prefix}-api-alb" # Naming our load balancer
  load_balancer_type = "application"

  # Referencing the default subnets
  subnets = var.subnets
  # Referencing the security group
  security_groups = [
    aws_security_group.entry-point.id,
  ]
}

resource "aws_lb_target_group" "back-end-workers" {
  name        = "${var.prefix}-back-end-workers"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc.id # Referencing the default VPC

  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "api-listener" {
  load_balancer_arn = aws_alb.back-end.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "api-secure-listener" {
  load_balancer_arn = aws_alb.back-end.arn
  protocol          = "HTTPS"
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  # certificate_arn   = var.wildcard-certificate
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back-end-workers.arn
  }

  depends_on = [ var.certificate ]
}

resource "aws_lb_listener_rule" "front-end" {
  listener_arn = aws_lb_listener.api-secure-listener.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front-end-workers.arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }
}

resource "aws_alb" "front-end" {
  name               = "${var.prefix}-web-alb" # Naming our load balancer
  load_balancer_type = "application"

  # Referencing the default subnets
  subnets = var.subnets
  # Referencing the security group
  security_groups = [
    aws_security_group.entry-point.id,
  ]
}

resource "aws_lb_target_group" "front-end-workers" {
  name        = "${var.prefix}-front-end-workers"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc.id # Referencing the default VPC

  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_alb.front-end.arn
  protocol          = "HTTP"
  port              = 80
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# resource "aws_lb_listener" "web-secure-listener" {
#   load_balancer_arn = aws_alb.front-end.arn
#   protocol          = "HTTPS"
#   port              = 443
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn   = var.apex-certificate
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.front-end-workers.arn
#   }
# }
