resource "aws_alb" "entry-point" {
  for_each           = toset(local.configuration.load_balancers)
  name               = "entry-point" # Naming our load balancer
  load_balancer_type = "application"

  # Referencing the default subnets
  subnets = local.subnets.*.id
  # Referencing the security group
  security_groups = [
    aws_security_group.entry-point[each.value].id,
  ]
}

# Creating a security group for load balancers
resource "aws_security_group" "entry-point" {
  for_each = toset(local.configuration.load_balancers)
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  ingress {
    from_port   = 443 # Allowing traffic in from port 80
    to_port     = 443
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

resource "aws_security_group" "alb-access" {
  for_each = toset(local.configuration.load_balancers)
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    # Only allowing traffic in from load balancers security group
    security_groups = [
      aws_security_group.entry-point[each.value].id,
    ]
  }

  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

resource "aws_alb_listener" "entry-point" {
  for_each = toset(local.configuration.load_balancers)

  load_balancer_arn = aws_alb.entry-point[each.value].arn
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

resource "aws_alb_listener" "secure-entry-point" {
  for_each = toset(local.configuration.load_balancers)

  load_balancer_arn = aws_alb.entry-point[each.value].arn
  protocol          = "HTTPS"
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  # certificate_arn   = aws_acm_certificate.entry-point[each.value].arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "200"
    }
  }
  # depends_on = [ aws_acm_certificate.entry-point[each.value] ]
}

data "aws_alb" "entry-point" {
  provider = aws.root
  name     = "entry-point"
}

# data "aws_alb_listener" "secure-entry-point" {
#   provider          = aws.root
#   load_balancer_arn = data.aws_alb.entry-point.arn
#   port              = 443
# }
