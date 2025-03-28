module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.34.0"
  for_each        = toset(local.configuration.sdlc.workspaces)
  cluster_name    = local.cluster_name
  cluster_version = "1.32"
  vpc_id          = module.vpc[each.value].vpc_id
  subnet_ids      = module.vpc[each.value].private_subnets

  cluster_endpoint_public_access = true
  create_iam_role                = true
  create_node_iam_role           = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    general = {
      name           = "general"
      instance_types = ["t3.small"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}
/**
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = module.eks[terraform.workspace].node_iam_role_name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = module.eks[terraform.workspace].node_iam_role_name
}
/**/
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = module.eks[terraform.workspace].cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = module.eks[terraform.workspace].cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = module.eks[terraform.workspace].cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = module.eks[terraform.workspace].cluster_iam_role_name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = module.eks[terraform.workspace].cluster_iam_role_name
}
