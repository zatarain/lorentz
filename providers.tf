provider "aws" {
  region = var.aws_region
  dynamic "assume_role" {
    for_each = toset(local.configuration.sdlc.roles)
    content {
      role_arn = "arn:aws:iam::${var.aws_env_id}:role/${assume_role.value}"
    }
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "root"
}
