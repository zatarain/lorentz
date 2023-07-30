module "mycv" {
  for_each = toset(local.configuration.sdlc.environments)
  source   = "./portfolio"
  name     = "curriculum-vitae"
  prefix   = "cv"
  zone_id  = local.kingdom.zone_id
  domain   = local.kingdom.name
  vpc      = local.vpc
  network  = data.aws_vpc.network
  subnets  = local.subnets.*.id
  subnet   = aws_subnet.deployment[each.value].id
  postgres = {
    username = var.database_username
  }

  wildcard-certificate = aws_acm_certificate.entry-point[local.kingdom.name].arn
  apex-certificate     = aws_acm_certificate.entry-point[local.kingdom.name].arn

  certificate = aws_acm_certificate.entry-point[local.kingdom.name]

  providers = {
    aws      = aws
    aws.root = aws.root
  }
}
