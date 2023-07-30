locals {
  zone_prefix = tomap({
    production  = "ulises."
    default     = ""
    staging     = "test."
    development = "beta."
  })

  availability_zone = tomap({
    default     = []
    production  = ["c", "b"]
    staging     = ["b", "c"]
    development = ["a", "b"]
  })

  cidr_block = tomap({
    default     = []
    production  = ["172.10.164.0/24", "172.10.180.0/24"]
    staging     = ["172.10.132.0/24", "172.10.148.0/24"]
    development = ["172.10.100.0/24", "172.10.116.0/24"]
  })

  settings = tomap({
    default = jsonencode({
      state = {
        name   = "lorentz-main"
        bucket = "lorentz-state"
      }
      sdlc = {
        users        = ["github"]
        roles        = []
        environments = []
        workspaces   = [terraform.workspace]
      }
      dns = {
        domains = ["zatara.in"]
        zones   = ["${local.zone_prefix[terraform.workspace]}zatara.in"]
      }
      networks          = ["default"]
      availability_zone = local.availability_zone[terraform.workspace]
      cidr_block        = local.cidr_block[terraform.workspace]
    })
  })

  environments = jsonencode({
    state = {
      name   = "lorentz-${terraform.workspace}"
      bucket = ""
    }
    sdlc = {
      users        = []
      roles        = ["github"]
      environments = [terraform.workspace]
      workspaces   = [terraform.workspace]
    }
    dns = {
      domains = []
      zones   = ["${local.zone_prefix[terraform.workspace]}zatara.in"]
    }
    networks          = []
    availability_zone = local.availability_zone[terraform.workspace]
    cidr_block        = local.cidr_block[terraform.workspace]
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
