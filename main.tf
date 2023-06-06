locals {
  kingdom = one(values(aws_route53_zone.kingdom))
  vpc     = one(values(aws_default_vpc.default_vpc))
  subnets = [
    one(values(aws_default_subnet.default_subnet_a)),
    one(values(aws_default_subnet.default_subnet_b)),
    one(values(aws_default_subnet.default_subnet_c)),
  ]
}
module "mycv" {
  # for_each = toset(local.configuration.vpc)
  source  = "./portfolio"
  name    = "curriculum-vitae"
  prefix  = "cv"
  zone_id = local.kingdom.zone_id
  vpc_id  = local.vpc.id
  subnets = local.subnets.*.id
}
