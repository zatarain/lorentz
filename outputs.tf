output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks[terraform.workspace].cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security Group ID attached to the cluster"
  value       = module.eks[terraform.workspace].cluster_security_group_id
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.eks[terraform.workspace].cluster_name
}

output "vpc-id" {
  description = "VPC ID"
  value       = module.vpc[terraform.workspace].default_vpc_id
}

output "vpc-private-subnets" {
  description = "VPC Private Subnets"
  value       = module.vpc[terraform.workspace].private_subnets
}

output "vpc-public-subnets" {
  description = "VPC Public Subnets"
  value       = module.vpc[terraform.workspace].public_subnets
}
