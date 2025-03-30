locals {
  cluster_name = "latte-${terraform.workspace}"
}

module "cluster" {
  source   = "./cluster"
  for_each = toset(local.configuration.sdlc.environments)
  name     = local.cluster_name
  vpc      = module.vpc[each.value]

  providers = {
    aws      = aws
    aws.root = aws.root
  }
}
