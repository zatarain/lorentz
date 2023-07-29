resource "aws_acm_certificate" "kingdom" {
  for_each          = toset(local.configuration.dns.zones)
  domain_name       = "*.${each.value}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "realm" {
  for_each          = toset(local.configuration.dns.zones)
  domain_name       = each.value
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  kingdom_validation_records = flatten([
    for key, certificate in aws_acm_certificate.kingdom : [
      for option in certificate.domain_validation_options : {
        domain  = option.domain_name
        name    = option.resource_record_name
        record  = option.resource_record_value
        type    = option.resource_record_type
        zone_id = aws_route53_zone.kingdom[key].zone_id
      }
    ]
  ])

  realm_validation_records = flatten([
    for key, certificate in aws_acm_certificate.realm : [
      for option in certificate.domain_validation_options : {
        domain  = option.domain_name
        name    = option.resource_record_name
        record  = option.resource_record_value
        type    = option.resource_record_type
        zone_id = aws_route53_zone.kingdom[key].zone_id
      }
    ]
  ])
}

resource "aws_route53_record" "kingdom-ssl" {
  for_each = {
    for record in local.kingdom_validation_records :
    "${record.type}/${record.name}" => record
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_route53_record" "realm-ssl" {
  for_each = {
    for record in local.realm_validation_records :
    "${record.type}/${record.name}" => record
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

locals {
  kingdom_validation_record_fqdns = {
    for domain in local.configuration.dns.zones : domain => [
      for record in aws_route53_record.kingdom-ssl :
      record.fqdn if record.zone_id == aws_route53_zone.kingdom[domain].zone_id
    ]
  }

  realm_validation_record_fqdns = {
    for domain in local.configuration.dns.zones : domain => [
      for record in aws_route53_record.realm-ssl :
      record.fqdn if record.zone_id == aws_route53_zone.kingdom[domain].zone_id
      # Filter has to be the same, as zone_id is the same for kingdom and realm
    ]
  }
}

resource "aws_acm_certificate_validation" "kingdom-ssl" {
  for_each = toset(local.configuration.dns.zones)

  certificate_arn         = aws_acm_certificate.kingdom[each.value].arn
  validation_record_fqdns = local.kingdom_validation_record_fqdns[each.value]
}

resource "aws_acm_certificate_validation" "realm-ssl" {
  for_each = toset(local.configuration.dns.zones)

  certificate_arn         = aws_acm_certificate.realm[each.value].arn
  validation_record_fqdns = local.realm_validation_record_fqdns[each.value]
}

resource "aws_acm_certificate" "entry-point" {
  for_each          = toset(local.configuration.dns.zones)
  domain_name       = each.value
  validation_method = "DNS"

  subject_alternative_names = ["*.${each.value}"]
  lifecycle {
    create_before_destroy = true
  }
}

/**
locals {
  entry-point-validation-records = flatten([
    for key, certificate in aws_acm_certificate.entry-point : [
      for option in certificate.domain_validation_options : {
        domain  = option.domain_name
        name    = option.resource_record_name
        record  = option.resource_record_value
        type    = option.resource_record_type
        zone_id = aws_route53_zone.kingdom[key].zone_id
      }
    ]
  ])
}

output "entry-point-validation-records" {
  value = local.entry-point-validation-records
}

resource "aws_route53_record" "entry-point-ssl" {
  for_each = {
    for record in local.entry-point-validation-records :
    "${record.type}/${record.name}/${record.domain}" => record
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
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
/**/
