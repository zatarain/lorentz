resource "aws_acm_certificate" "kingdom" {
  for_each          = toset(local.configuration.dns.domains)
  domain_name       = "*.${each.value}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

/**
locals {
  ssl_validation_records = tomap(flatten([
    for kingdom, certificate in aws_acm_certificate.kingdom : {
      for index, option in certificate.domain_validation_options : format("${kingdom}-%d", index) => {
        domain  = kingdom
        name    = option.resource_record_name
        record  = option.resource_record_value
        type    = option.resource_record_type
        zone_id = aws_route53_zone.kingdom[kingdom].zone_id
      }
    }
  ]))
}

resource "aws_route53_record" "ssl" {
  for_each = local.ssl_validation_records

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

locals {
  validation_record_fqdns = {
    for domain in local.configuration.dns.domains : domain => [
      for record in aws_route53_record.ssl :
      record.fqdn if record.zone_id == aws_route53_zone.kingdom[domain].zone_id
    ]
  }
}

resource "aws_acm_certificate_validation" "ssl" {
  for_each                = toset(local.configuration.dns.domains)
  certificate_arn         = aws_acm_certificate.kingdom[each.value].arn
  validation_record_fqdns = local.validation_record_fqdns[each.value]
}
/**/
