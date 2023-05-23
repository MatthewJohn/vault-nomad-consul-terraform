data "vault_approle_auth_backend_role_id" "connect_ca" {
  backend   = var.datacenter.approle_mount_path
  role_name = var.datacenter.connect_ca_approle_role_name
}

resource "vault_approle_auth_backend_role_secret_id" "connect_ca" {
  backend   = var.datacenter.approle_mount_path
  role_name = var.datacenter.connect_ca_approle_role_name

  metadata = jsonencode(
    {
      "node_name"  = "consul-server-${var.datacenter.name}-${var.hostname}"
      "datacenter" = var.datacenter.name
    }
  )
}
