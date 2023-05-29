data "vault_approle_auth_backend_role_id" "consul_template" {
  backend   = var.region.approle_mount_path
  role_name = var.region.client_consul_template_approle_role_name
}

resource "vault_approle_auth_backend_role_secret_id" "consul_template" {
  backend   = var.region.approle_mount_path
  role_name = var.region.client_consul_template_approle_role_name

  metadata = jsonencode(
    {
      "node_name"  = "nomad-client-${var.region.name}-${var.hostname}"
      "region" = var.region.name
    }
  )
}
