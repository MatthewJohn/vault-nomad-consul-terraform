# Token for consul agent service registration
resource "consul_acl_policy" "agent_service_role" {

  name = "consul-server-service-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
service_prefix "consul-" {
   policy = "write"
}
EOF
}


resource "vault_consul_secret_backend_role" "agent_service_role" {
  name    = "consul-server-service-role"
  backend = vault_consul_secret_backend.this.path

  consul_policies = [
    consul_acl_policy.agent_service_role.name
  ]
}
