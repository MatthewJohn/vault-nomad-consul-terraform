data "vault_approle_auth_backend_role_id" "consul_template" {
  backend   = var.datacenter.approle_mount_path
  role_name = var.datacenter.client_consul_template_approle_role_name
}

resource "vault_approle_auth_backend_role_secret_id" "consul_template" {
  backend   = var.datacenter.approle_mount_path
  role_name = var.datacenter.client_consul_template_approle_role_name

  metadata = jsonencode(
    {
      "node_name"  = "consul-client-${var.datacenter.name}-${var.hostname}"
      "datacenter" = var.datacenter.name
    }
  )
}
