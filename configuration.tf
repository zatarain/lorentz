locals {
  zone_prefix = tomap({
    production  = "ulises."
    default     = ""
    staging     = "test."
    development = "beta."
  })

  availability_zone = tomap({
    default     = []
    production  = ["a", "b", "c"]
    staging     = ["a", "b", "c"]
    development = ["a", "b", "c"]
  })

  cidr_block = tomap({
    default     = []
    production  = ["172.10.168.0/24", "172.10.196.0/24", "172.10.223.0/24"]
    staging     = ["172.10.85.0/24", "172.10.113.0/24", "172.10.140.0/24"]
    development = ["172.10.0.0/24", "172.10.28.0/24", "172.10.57.0/24"]
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
