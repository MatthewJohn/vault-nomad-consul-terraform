resource "vault_token" "admin" {
  role_name = var.admin_role_name

  policies = [vault_policy.admin.name]

  renewable = true
  ttl       = "24h"

  renew_min_lease = 43200
  renew_increment = 86400

  metadata = {
    "purpose" = "admin-role"
  }
}
