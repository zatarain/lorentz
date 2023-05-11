locals {
  settings = tomap({
    default = jsonencode({
      state = {
        name   = "lorentz-main"
        bucket = "lorentz-state"
      }
      sdlc = {
        users = ["github"]
        roles = []
      }
    })
  })

  environments = jsonencode({
    state = {
      name   = "lorentz-${terraform.workspace}"
      bucket = "" # lorentz-${terraform.workspace}-state
    }
    sdlc = {
      users = []
      roles = ["github"]
    }
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
