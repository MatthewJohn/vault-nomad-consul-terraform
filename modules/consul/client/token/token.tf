resource "consul_acl_token" "this" {
  description = "Consul agent token for ${var.docker_host.hostname}"
  policies    = [consul_acl_policy.this.name]
  local       = true
}

data "consul_acl_token_secret_id" "this" {
  accessor_id = consul_acl_token.this.id
}