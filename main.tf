module "mycv" {
  for_each = toset(local.configuration.sdlc.environments)
  source   = "./portfolio"
  name     = "curriculum-vitae"
  prefix   = "cv"
  zone_id  = local.kingdom.zone_id
  domain   = local.kingdom.name
  vpc      = local.vpc
  subnets  = local.subnets.*.id
  postgres = {
    username = var.database_username
  }

  wildcard-certificate = aws_acm_certificate.kingdom[local.kingdom.name].arn
  apex-certificate     = aws_acm_certificate.realm[local.kingdom.name].arn
}
