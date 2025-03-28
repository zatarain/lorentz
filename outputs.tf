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
