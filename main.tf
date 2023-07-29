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

  wildcard-certificate = aws_acm_certificate.entry-point[local.kingdom.name].arn
  apex-certificate     = aws_acm_certificate.entry-point[local.kingdom.name].arn

  certificate        = aws_acm_certificate.entry-point[local.kingdom.name]
  load-balancer      = data.aws_alb.entry-point
  secure-entry-point = data.aws_alb_listener.secure-entry-point

  providers = {
    aws      = aws
    aws.root = aws.root
  }
}
