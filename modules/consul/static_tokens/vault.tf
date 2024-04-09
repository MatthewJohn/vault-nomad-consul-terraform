resource "vault_kv_secret_v2" "static_token" {
  mount               = var.datacenter.consul_server_token.mount
  name                = var.datacenter.consul_server_token.name
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      server_token         = data.consul_acl_token_secret_id.consul_server_token.secret_id
      server_service_token = data.consul_acl_token_secret_id.agent_service_role.secret_id
      default_token        = data.consul_acl_token_secret_id.default_service_role.secret_id
    }
  )
}
