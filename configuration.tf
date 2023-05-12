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
        users = ["github"]
        roles = []
        hub   = ""
      }
      dns = {
        domains = ["zatara.in"]
        zones   = []
      }
      vpc = []
    })
  })

  environments = jsonencode({
    state = {
      name   = "lorentz-${terraform.workspace}"
      bucket = ""
    }
    sdlc = {
      users = []
      roles = ["github"]
      hub   = terraform.workspace
    }
    dns = {
      domains = []
      zones   = ["${local.zone_prefix[terraform.workspace]}zatara.in"]
    }
    vpc = [terraform.workspace]
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
