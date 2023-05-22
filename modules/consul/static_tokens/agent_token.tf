resource "consul_acl_policy" "agent_role" {

  name = "consul-server-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
node_prefix "consul-server-${var.datacenter.name}-" {
  policy = "write"
}
node_prefix "" {
  policy = "read"
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
