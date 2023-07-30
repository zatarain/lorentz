resource "aws_route53_record" "api" {
  zone_id = var.zone_id
  name    = "api"
  type    = "A"
  alias {
    zone_id                = var.load-balancer.zone_id
    name                   = var.load-balancer.dns_name
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = var.zone_id
  name    = ""
  type    = "A"
  alias {
    zone_id                = var.load-balancer.zone_id
    name                   = var.load-balancer.dns_name
    evaluate_target_health = true
  }
}
