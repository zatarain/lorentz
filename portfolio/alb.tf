resource "aws_alb" "back-end" {
  name               = "${var.prefix}-api-alb" # Naming our load balancer
  load_balancer_type = "application"

  # Referencing the default subnets
  subnets = var.subnets
  # Referencing the security group
  security_groups = [
    aws_security_group.back-end-entry-point.id,
  ]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "back-end-entry-point" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_lb_target_group" "back-end-workers" {
  name        = "${var.prefix}-back-end-workers"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id # Referencing the default VPC

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
  protocol          = "TLS"
  port              = 443
  alpn_policy       = "HTTP2Preferred"
  certificate_arn   = var.certificate
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back-end-workers.arn
  }
}

resource "aws_alb" "front-end" {
  name               = "${var.prefix}-web-alb" # Naming our load balancer
  load_balancer_type = "application"

  # Referencing the default subnets
  subnets = var.subnets
  # Referencing the security group
  security_groups = [
    aws_security_group.front-end-entry-point.id,
  ]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "front-end-entry-point" {
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_lb_target_group" "front-end-workers" {
  name        = "${var.prefix}-front-end-workers"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id # Referencing the default VPC

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

resource "aws_lb_listener" "web-secure-listener" {
  load_balancer_arn = aws_alb.front-end.arn
  protocol          = "TLS"
  port              = 443
  alpn_policy       = "HTTP2Preferred"
  certificate_arn   = var.certificate
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front-end-workers.arn
  }
}
