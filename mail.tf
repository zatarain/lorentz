resource "aws_secretsmanager_secret" "crm-service" {
  name = "crm-service"
}

resource "aws_secretsmanager_secret_version" "crm-service" {
  secret_id = aws_secretsmanager_secret.crm-service.id
  secret_string = jsonencode({
    code  = "change me"
    dkim  = "change me"
    dmarc = "change me"
  })
}

data "aws_secretsmanager_secret_version" "crm-current" {
  secret_id = aws_secretsmanager_secret.crm-service.id
}

locals {
  mail-server = terraform.workspace == "production" ? "" : trimsuffix(local.zone_prefix[terraform.workspace], ".")
  mail-secret = jsondecode(data.aws_secretsmanager_secret_version.crm-current.secret_string)
}

resource "aws_route53_record" "crm-code" {
  for_each = toset(local.records-for-kingdoms)
  provider = aws.root
  zone_id  = data.aws_route53_zone.realm[each.value].zone_id
  name     = local.mail-server == "" ? "@" : local.mail-server
  type     = "TXT"
  ttl      = 172800
  records  = [local.mail-secret["code"]]
}

resource "aws_route53_record" "crm-dkim" {
  for_each = toset(local.records-for-kingdoms)
  provider = aws.root
  zone_id  = data.aws_route53_zone.realm[each.value].zone_id
  name     = "mail._domainkey.${local.mail-server}"
  type     = "TXT"
  ttl      = 172800
  records  = [local.mail-secret["dkim"]]
}

resource "aws_route53_record" "crm-dmarc" {
  for_each = toset(local.records-for-kingdoms)
  provider = aws.root
  zone_id  = data.aws_route53_zone.realm[each.value].zone_id
  name     = "_dmarc.${local.mail-server}"
  type     = "TXT"
  ttl      = 172800
  records  = [local.mail-secret["dmarc"]]
}
