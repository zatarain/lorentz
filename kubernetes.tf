module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.34.0"
  for_each        = toset(local.configuration.sdlc.workspaces)
  cluster_name    = local.cluster_name
  cluster_version = "1.32"

  vpc_id                         = module.vpc[each.value].vpc_id
  subnet_ids                     = module.vpc[each.value].private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-one"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }

    two = {
      name = "node-group-two"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
