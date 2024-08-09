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
