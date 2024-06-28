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

  cidr_block           = "172.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Deployment"
  }
}

resource "aws_security_group" "default" {
  for_each = toset(local.configuration.sdlc.environments)
  name     = "default-${each.value}"
  vpc_id   = data.aws_vpc.network.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  count    = length(local.configuration.cidr_block)

  vpc_id     = data.aws_vpc.network.id
  cidr_block = local.configuration.cidr_block[count.index]

  availability_zone       = "eu-west-1${local.configuration.availability_zone[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "${terraform.workspace} - ${local.configuration.availability_zone[count.index]}"
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
  count    = length(aws_subnet.deployment)

  resource_arn       = aws_subnet.deployment[count.index].arn
  resource_share_arn = aws_ram_resource_share.shared-networks[terraform.workspace].arn
}

resource "aws_ram_principal_association" "deployment-account" {
  provider = aws.root
  for_each = toset(local.configuration.sdlc.environments)

  principal          = var.aws_env_id
  resource_share_arn = aws_ram_resource_share.shared-networks[each.value].arn
}

resource "aws_route_table" "public-access" {
  provider = aws.root
  for_each = toset(local.configuration.networks)

  vpc_id   = data.aws_vpc.network.id

  tags   = {
    Name = "deployment-public-access"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-access[each.value].id
  }
}

resource "aws_route_table_association" "public" {
  provider = aws.root
  count = length(local.route-associations)

  subnet_id      = local.route-associations[count.index][0]
  route_table_id = aws_route_table.public-access[local.route-associations[count.index][1]].id
}

data "aws_internet_gateway" "environment-internet" {
  filter {
    name   = "attachment.vpc-id"
    values = [local.vpc.id]
  }
}

resource "aws_route_table" "public-access-environment" {
  for_each = toset(local.configuration.sdlc.workspaces)

  vpc_id   = local.vpc.id

  tags   = {
    Name = "deployment-public-access-${each.value}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.environment-internet.id
  }
}

resource "aws_route_table_association" "public-environment" {
  count = length(local.environment-route-associations)

  subnet_id      = local.environment-route-associations[count.index][0]
  route_table_id = aws_route_table.public-access-environment[
    local.environment-route-associations[count.index][1]
  ].id
}

resource "aws_eip" "nat" {
  count    = length(aws_subnet.deployment)
  provider = aws.root
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  provider      = aws.root
  count         = length(aws_subnet.deployment)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.deployment[count.index].id

  tags = {
    Name      = "${terraform.workspace} NAT"
    Terraform = true
  }
}

locals {
  vpc = one(values(aws_default_vpc.default_vpc))
  subnets = [
    one(values(aws_default_subnet.default_subnet_a)),
    one(values(aws_default_subnet.default_subnet_b)),
    one(values(aws_default_subnet.default_subnet_c)),
  ]
  route-associations = setproduct(aws_subnet.deployment[*].id, keys(aws_route_table.public-access))
  environment-route-associations = setproduct(local.subnets[*].id, keys(aws_route_table.public-access-environment))
}
