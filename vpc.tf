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

data "aws_vpc" "network" {
  provider = aws.root
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

locals {
  vpc = one(values(aws_default_vpc.default_vpc))
  subnets = [
    one(values(aws_default_subnet.default_subnet_a)),
    one(values(aws_default_subnet.default_subnet_b)),
    one(values(aws_default_subnet.default_subnet_c)),
  ]
}
