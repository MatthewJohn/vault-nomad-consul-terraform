
resource "consul_acl_token" "vault_secret_engine" {
  description = "Vault secret engine auth token ${var.datacenter.name}"
  policies    = ["global-management"]
  local       = true
}

data "consul_acl_token_secret_id" "vault_secret_engine" {
  accessor_id = consul_acl_token.vault_secret_engine.accessor_id
}

resource "vault_consul_secret_backend" "this" {
  path        = var.datacenter.consul_engine_mount_path
  description = "Manages the Consul backend for ${var.datacenter.name}"
  address     = var.datacenter.address_wo_protocol
  # ca_cert     = var.datacenter.root_cert_public_key
  local       = true
  token       = data.consul_acl_token_secret_id.vault_secret_engine.secret_id
}
