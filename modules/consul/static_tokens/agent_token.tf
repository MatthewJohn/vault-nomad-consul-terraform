resource "consul_acl_policy" "agent_role" {

  for_each = local.consul_server_map

  name = "agent-${var.datacenter.name}-${each.key}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
node "${each.key}" {
  policy = "write"
}

node "" {
  policy = "read"
}

agent "${each.key}" {
  policy = "write"
}
EOF
}

resource "consul_acl_token" "agent_token" {
  for_each = local.consul_server_map

  description = "Agent token ${each.key}.${var.datacenter.name}"

  policies = [consul_acl_policy.agent_role[each.key].name]

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
