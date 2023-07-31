resource "aws_alb_target_group" "back-end" {
  name        = "${var.prefix}-back-end"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.network.id

  health_check {
    matcher = "200,301,302"
    path    = "/"
  }

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_alb_listener_rule" "back-end" {
  listener_arn = var.secure-entry-point.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.back-end.arn
  }

  condition {
    host_header {
      values = ["api.${var.domain}"]
    }
  }
}

resource "aws_alb_target_group" "front-end" {
  name        = "${var.prefix}-front-end"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.network.id

  health_check {
    matcher = "200,301,302"
    path    = "/"
  }

  tags = {
    Environment = terraform.workspace
  }
}

resource "aws_alb_listener_rule" "front-end" {
  listener_arn = var.secure-entry-point.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.front-end.arn
  }

  condition {
    host_header {
      values = [var.domain]
    }
  }
}
