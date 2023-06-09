resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = "api"
  type    = "A"
  alias {
    zone_id                = aws_alb.back-end.zone_id
    name                   = aws_alb.back-end.dns_name
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = var.zone_id
  name    = ""
  type    = "A"
  alias {
    zone_id                = aws_alb.front-end.zone_id
    name                   = aws_alb.front-end.dns_name
    evaluate_target_health = true
  }
}
