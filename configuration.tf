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
        hub   = "lorentz"
      }
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
      hub   = "lorentz"
    }
  })

  configuration = jsondecode(lookup(local.settings, terraform.workspace, local.environments))
}
