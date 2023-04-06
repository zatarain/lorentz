resource "aws_route53_delegation_set" "dns" {
  reference_name = "My DNS"
}

resource "aws_route53domains_registered_domain" "lattephp-net" {
  domain_name = "lattephp.net"

  name_server {
    name = aws_route53_delegation_set.dns.name_servers[0]
  }

  name_server {
    name = aws_route53_delegation_set.dns.name_servers[1]
  }
}

resource "aws_route53_zone" "zatarain-co-uk" {
  name              = aws_route53domains_registered_domain.lattephp-net.domain_name
  delegation_set_id = aws_route53_delegation_set.dns.id
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.zatarain-co-uk.zone_id
  name    = "www"
  type    = "A"
  alias {
    zone_id                = aws_alb.portfolio.zone_id
    name                   = aws_alb.portfolio.dns_name
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.zatarain-co-uk.zone_id
  name    = ""
  type    = "A"
  alias {
    zone_id                = aws_alb.portfolio.zone_id
    name                   = aws_alb.portfolio.dns_name
    evaluate_target_health = true
  }
}
