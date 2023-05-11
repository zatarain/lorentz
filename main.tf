
resource "aws_ecr_repository" "hub" {
  name = local.configuration.sdlc.hub
}

resource "aws_route53_delegation_set" "dns" {
  reference_name = "Default Delegation Set"
}

/**
module "mycv" {
  source = "./portfolio"
  name   = "curriculum-vitae"
  prefix = "cv"
  hub    = aws_ecr_repository.hub
  dns    = aws_route53_delegation_set.dns
  vpc_id = aws_default_vpc.default_vpc.id
  subnets = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    aws_default_subnet.default_subnet_c.id,
  ]
}
/**/
