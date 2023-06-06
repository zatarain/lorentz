locals {
  zone_prefix = tomap({
    production  = ""
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
      }
      dns = {
        domains = ["zatara.in"]
        zones   = []
      }
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
    }
    dns = {
      domains = []
      zones   = ["${local.zone_prefix[terraform.workspace]}zatara.in"]
    }
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
