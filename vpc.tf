# Providing a reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
  for_each = toset(local.configuration.sdlc.environments)
}

# Providing a reference to our default subnets
resource "aws_default_subnet" "default_subnet_a" {
  for_each          = toset(local.configuration.sdlc.environments)
  availability_zone = "eu-west-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  for_each          = toset(local.configuration.sdlc.environments)
  availability_zone = "eu-west-1b"
}

resource "aws_default_subnet" "default_subnet_c" {
  for_each          = toset(local.configuration.sdlc.environments)
  availability_zone = "eu-west-1c"
}

locals {
  vpc = one(values(aws_default_vpc.default_vpc))
  subnets = [
    one(values(aws_default_subnet.default_subnet_a)),
    one(values(aws_default_subnet.default_subnet_b)),
    one(values(aws_default_subnet.default_subnet_c)),
  ]
}
