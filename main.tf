module "mycv" {
  for_each = toset(local.configuration.sdlc.environments)
  source   = "./portfolio"
  name     = "curriculum-vitae"
  prefix   = "cv"
  zone_id  = local.kingdom.zone_id
  domain   = local.kingdom.name
  vpc_id   = local.vpc.id
  subnets  = local.subnets.*.id
  #certificate = aws_acm_certificate.kingdom.arn
}
