resource "random_password" "password" {
  length  = 49
  special = false
}

resource "harbor_robot_account" "system" {
  name        = var.name
  description = "Robot account for ${var.name}"
  level       = "system"
  secret      = resource.random_password.password.result
  dynamic "permissions" {
    for_each = toset(var.harbor_projects)

    content {
      access {
        action   = "pull"
        resource = "repository"
      }
      kind      = "project"
      namespace = permissions.value
    }
  }
}