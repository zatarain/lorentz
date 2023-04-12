resource "aws_route53_delegation_set" "dns" {
  reference_name = "My DNS"
}

resource "aws_route53domains_registered_domain" "zatarain" {
  domain_name = "zatara.in"

  dynamic "name_server" {
    for_each = toset(aws_route53_delegation_set.dns.name_servers)
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_zone" "zatarain" {
  name              = aws_route53domains_registered_domain.zatarain.domain_name
  delegation_set_id = aws_route53_delegation_set.dns.id
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
