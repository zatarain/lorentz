# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
  for_each = toset(local.configuration.sdlc.workspaces)

  tags = {
    Name = terraform.workspace
  }
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  for_each          = toset(local.configuration.sdlc.workspaces)
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${terraform.workspace} A"
  }
}

resource "aws_default_subnet" "default_subnet_b" {
  for_each          = toset(local.configuration.sdlc.workspaces)
  availability_zone = "eu-west-1b"
  tags = {
    Name = "${terraform.workspace} B"
  }
}

resource "aws_default_subnet" "default_subnet_c" {
  for_each          = toset(local.configuration.sdlc.workspaces)
  availability_zone = "eu-west-1c"
  tags = {
    Name = "${terraform.workspace} C"
  }
}

resource "aws_vpc" "deployment" {
  for_each = toset(local.configuration.networks)

  cidr_block = local.configuration.cidr_block

  tags = {
    Name = "Deployment"
  }
}

resource "aws_internet_gateway" "internet-access" {
  for_each = toset(local.configuration.networks)
  vpc_id   = aws_vpc.deployment[each.value].id
}

data "aws_vpc" "network" {
  provider = aws.root

  tags = {
    Name = "Deployment"
  }
}

resource "aws_subnet" "deployment" {
  provider = aws.root
  for_each = toset(local.configuration.sdlc.environments)

  availability_zone = "eu-west-1${local.configuration.availability_zone}"
  vpc_id            = data.aws_vpc.network.id
  cidr_block        = local.configuration.cidr_block

  tags = {
    Name = "Deployment (${terraform.workspace})"
  }
}

data "aws_subnets" "deployment" {
  provider = aws.root

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.network.id]
  }
}

resource "aws_ram_resource_share" "shared-networks" {
  provider = aws.root
  for_each = toset(local.configuration.sdlc.environments)

  name                      = "Shared Networks - ${each.value}"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "deployment-subnet" {
  provider = aws.root
  for_each = toset(local.configuration.sdlc.environments)

  resource_arn       = aws_subnet.deployment[each.value].arn
  resource_share_arn = aws_ram_resource_share.shared-networks[each.value].arn
}

resource "aws_ram_principal_association" "deployment-account" {
  provider = aws.root
  for_each = toset(local.configuration.sdlc.environments)

  principal          = var.aws_env_id
  resource_share_arn = aws_ram_resource_share.shared-networks[each.value].arn
}

locals {
  vpc = one(values(aws_default_vpc.default_vpc))
  subnets = [
    one(values(aws_default_subnet.default_subnet_a)),
    one(values(aws_default_subnet.default_subnet_b)),
    one(values(aws_default_subnet.default_subnet_c)),
  ]
}
