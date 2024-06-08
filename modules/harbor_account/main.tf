resource "harbor_robot_account" "system" {
  name        = data.vault_kv_secret_v2.this.data.username
  description = "Robot account for ${data.vault_kv_secret_v2.this.data.username}"
  level       = "system"
  secret      = data.vault_kv_secret_v2.this.data.password
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