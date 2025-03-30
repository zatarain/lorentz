module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.34.0"
  cluster_name    = var.name
  cluster_version = "1.32"
  vpc_id          = var.vpc.vpc_id
  subnet_ids      = var.vpc.private_subnets

  cluster_endpoint_public_access = true
  create_iam_role                = false
  create_node_iam_role           = false

  iam_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github"

  enable_cluster_creator_admin_permissions = true
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    general = {
      name           = "general"
      instance_types = ["t3.nano"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}

data "aws_caller_identity" "current" {}
