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


resource "vault_consul_secret_backend_role" "agent_role" {
  name    = "consul-server-role"
  backend = vault_consul_secret_backend.this.path

  consul_policies = [
    consul_acl_policy.agent_role.name
  ]
}
