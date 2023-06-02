resource "aws_route53_delegation_set" "dns" {
  reference_name = "Delegation Set (${terraform.workspace})"
}

resource "aws_route53domains_registered_domain" "realm" {
  for_each    = toset(local.configuration.dns.domains)
  domain_name = each.value

  dynamic "name_server" {
    for_each = toset(aws_route53_delegation_set.dns.name_servers)
    content {
      name = name_server.value
    }
  }
}

resource "aws_route53_zone" "kingdom" {
  for_each          = toset(local.configuration.dns.zones)
  name              = each.value
  delegation_set_id = aws_route53_delegation_set.dns.id
}
