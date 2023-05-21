resource "consul_acl_token" "agent_token" {
  for_each = local.consul_server_map

  description = "Agent token ${each.key}.${var.datacenter.name}"

  node_identities {
    node_name  = each.key
    datacenter = var.datacenter.name
  }
}

resource "vault_kv_secret_v2" "agent_token" {
  for_each = local.consul_server_map

  mount = var.vault_cluster.consul_static_mount_path
  name  = "${var.datacenter.name}/agent-tokens/${each.key}"

  data_json = jsonencode(
    {
      token = consul_acl_token.agent_token[each.key].accessor_id
    }
  )
}
