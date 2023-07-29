locals {
  zone_prefix = tomap({
    production  = "ulises."
    default     = ""
    staging     = "test."
    development = "beta."
  })

  availability_zone = tomap({
    default     = "c"
    production  = "c"
    staging     = "b"
    development = "a"
  })

  cidr_block = tomap({
    default     = "172.10.0.0/16"
    production  = "172.10.32.0/20"
    staging     = "172.10.16.0/20"
    development = "172.10.0.0/20"
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
      load_balancers    = ["default"]
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
    load_balancers    = []
    availability_zone = local.availability_zone[terraform.workspace]
    cidr_block        = local.cidr_block[terraform.workspace]
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
