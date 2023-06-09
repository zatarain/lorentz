locals {
  name_servers = [
    "ns-11.awsdns-01.com",
    "ns-1146.awsdns-15.org",
    "ns-1999.awsdns-57.co.uk",
    "ns-887.awsdns-46.net",
  ]
}

resource "aws_route53_delegation_set" "dns" {
  reference_name = "Delegation Set (${terraform.workspace})"
}

resource "aws_route53domains_registered_domain" "realm" {
  for_each    = toset(local.configuration.dns.domains)
  domain_name = each.value

  dynamic "name_server" {
    for_each = toset(terraform.workspace == "default" ? aws_route53_delegation_set.dns.name_servers : local.name_servers)
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_zone" "kingdom" {
  for_each          = toset(local.configuration.dns.zones)
  name              = each.value
  delegation_set_id = terraform.workspace == "default" ? aws_route53_delegation_set.dns.id : null
}

locals {
  kingdom = one(values(aws_route53_zone.kingdom))
}
