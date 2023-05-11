resource "aws_route53domains_registered_domain" "zatarain" {
  domain_name = "zatara.in"

  dynamic "name_server" {
    for_each = toset(var.dns.name_servers)
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_zone" "zatarain" {
  name              = aws_route53domains_registered_domain.zatarain.domain_name
  delegation_set_id = var.dns.id
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.zatarain.zone_id
  name    = "api"
  type    = "A"
  alias {
    zone_id                = aws_alb.portfolio.zone_id
    name                   = aws_alb.portfolio.dns_name
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.zatarain.zone_id
  name    = ""
  type    = "A"
  alias {
    zone_id                = aws_alb.portfolio.zone_id
    name                   = aws_alb.portfolio.dns_name
    evaluate_target_health = true
  }
}
