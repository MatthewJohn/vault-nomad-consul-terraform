resource "consul_acl_policy" "client_role" {

  name = "consul-client-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
node_prefix "consul-client-${var.datacenter.name}-" {
  policy = "write"
}
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}

service "node_exporter" {
  policy = "write"
}
EOF
}


resource "vault_consul_secret_backend_role" "client_role" {
  name    = "consul-client-role"
  backend = vault_consul_secret_backend.this.path

  consul_policies = [
    consul_acl_policy.client_role.name
  ]
}
