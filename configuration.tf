locals {
  zone_prefix = tomap({
    production  = "ulises."
    default     = ""
    staging     = "test."
    development = "beta."
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
      load_balancers = ["default"]
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
    load_balancers = []
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
