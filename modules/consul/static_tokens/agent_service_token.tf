# Token for consul agent service registration
resource "consul_acl_policy" "agent_service_role" {

  name = "consul-server-service-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
service_prefix "consul-" {
   policy = "write"
}

service "node_exporter" {
   policy = "write"
}
EOF
}

resource "consul_acl_token" "agent_service_role" {
  description = "consul-server-service-${var.datacenter.name}"
  policies    = ["${consul_acl_policy.agent_service_role.name}"]
  local       = true
}

data "consul_acl_token_secret_id" "agent_service_role" {
  accessor_id = consul_acl_token.agent_service_role.id
}
