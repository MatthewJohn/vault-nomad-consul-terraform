resource "consul_acl_policy" "agent_role" {

  name = "consul-server-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
node "" {
  policy = "write"
}
agent "" {
  policy = "write"
}
agent_prefix "" {
  policy = "write"
}
service "" {
  policy = "read"
}
node_prefix "" {
   policy = "write"
}
service_prefix "" {
   policy = "read"
}
EOF
}

resource "consul_acl_token" "consul_server_token" {
  description = "consul-server-${var.datacenter.name}"
  policies = ["${consul_acl_policy.agent_role.name}"]
  local = true
}

data "consul_acl_token_secret_id" "consul_server_token" {
  accessor_id = consul_acl_token.consul_server_token.id
}
