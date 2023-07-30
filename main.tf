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
  subnet   = aws_subnet.deployment.*.id
  postgres = {
    username = var.database_username
  }

  # wildcard-certificate = aws_acm_certificate.entry-point[local.kingdom.name].arn
  # apex-certificate     = aws_acm_certificate.entry-point[local.kingdom.name].arn

  certificate        = aws_acm_certificate.entry-point[local.kingdom.name]
  load-balancer      = aws_alb.entry-point[each.value]
  secure-entry-point = aws_alb_listener.secure-entry-point[each.value]
  alb-access         = aws_security_group.alb-access[each.value]
  alb-group          = aws_security_group.entry-point[each.value]

  default-security-group = aws_security_group.default[each.value]

  providers = {
    aws      = aws
    aws.root = aws.root
  }
}
