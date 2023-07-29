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

  certificate        = aws_acm_certificate.entry-point[local.kingdom.name]
  load-balancer      = data.aws_alb.entry-point
  secure-entry-point = data.aws_alb_listener.secure-entry-point
  alb-access         = data.aws_security_group.alb-access

  task-runner           = data.aws_iam_role.task-runner
  task-command-executor = data.aws_iam_role.task-command-executor

  providers = {
    aws      = aws
    aws.root = aws.root
  }
}
