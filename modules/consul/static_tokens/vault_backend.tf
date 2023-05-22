
resource "consul_acl_token" "vault_secret_engine" {
  description = "Vault secret engine auth token ${var.datacenter.name}"
  policies    = ["global-management"]
  local       = true
}

data "consul_acl_token_secret_id" "vault_secret_engine" {
  accessor_id = consul_acl_token.vault_secret_engine.accessor_id
}

resource "vault_consul_secret_backend" "this" {
  path        = "consul-${var.datacenter.name}"
  description = "Manages the Consul backend for ${var.datacenter.name}"
  address     = var.vault_cluster.address
  token       = data.consul_acl_token_secret_id.vault_secret_engine.secret_id
}