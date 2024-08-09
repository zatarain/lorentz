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
  mail-secret = jsondecode(data.aws_secretsmanager_secret_version.crm-current.secret_string)
}

resource "aws_route53_record" "crm-code" {
  for_each = toset(local.configuration.sdlc.environments)
  zone_id  = local.kingdom.zone_id
  name     = ""
  type     = "TXT"
  ttl      = 172800
  records  = [local.mail-secret["code"]]
}

resource "aws_route53_record" "crm-dkim" {
  for_each = toset(local.configuration.sdlc.environments)
  zone_id  = local.kingdom.zone_id
  name     = "mail._domainkey"
  type     = "TXT"
  ttl      = 172800
  records  = [local.mail-secret["dkim"]]
}

resource "aws_route53_record" "crm-dmarc" {
  for_each = toset(local.configuration.sdlc.environments)
  zone_id  = local.kingdom.zone_id
  name     = "_dmarc"
  type     = "TXT"
  ttl      = 172800
  records  = [local.mail-secret["dmarc"]]
}
