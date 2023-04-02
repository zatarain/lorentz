resource "aws_ecs_cluster" "portfolio" {
  name = var.name
}

resource "aws_ecr_repository" "hub" {
  name = var.repository
}
