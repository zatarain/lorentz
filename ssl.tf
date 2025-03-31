resource "aws_acm_certificate" "entry-point" {
  for_each          = toset(local.configuration.dns.zones)
  domain_name       = each.value
  validation_method = "DNS"

  subject_alternative_names = ["*.${each.value}"]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "entry-point-ssl" {
  for_each = {
    for domain in local.configuration.dns.zones :
    domain => one([
      for option in aws_acm_certificate.entry-point[domain].domain_validation_options :
      option if option.domain_name == domain
    ])
  }

  allow_overwrite = true
  name            = each.value.resource_record_name
  records         = [each.value.resource_record_value]
  ttl             = 60
  type            = each.value.resource_record_type
  zone_id         = aws_route53_zone.kingdom[each.key].zone_id
}

locals {
  entry-point-validation-record-fqdns = {
    for domain in local.configuration.dns.zones : domain => [
      for record in aws_route53_record.entry-point-ssl :
      record.fqdn if record.zone_id == aws_route53_zone.kingdom[domain].zone_id
    ]
  }
}

resource "aws_acm_certificate_validation" "entry-point-ssl" {
  for_each = toset(local.configuration.dns.zones)

  certificate_arn         = aws_acm_certificate.entry-point[each.value].arn
  validation_record_fqdns = local.entry-point-validation-record-fqdns[each.value]
}
