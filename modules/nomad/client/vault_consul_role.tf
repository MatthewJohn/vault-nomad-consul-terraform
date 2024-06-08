
# Create policy for nomad client in consul
# and create vault consul_engine role to
# allow consul-template to generate a token
# during startup

resource "consul_acl_policy" "nomad_client" {
  name = "nomad-${var.region.name}-${var.datacenter.name}-client-${var.docker_host.hostname}"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules = <<-RULE
# As per https://developer.hashicorp.com/nomad/docs/integrations/consul-integration
key_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

agent_prefix "" {
  policy = "read"
}

node_prefix "" {
  policy = "read"
}

node "consul-client-${var.consul_datacenter.name}-${var.docker_host.hostname}" {
  policy = "write"
}

agent "consul-client-${var.consul_datacenter.name}-${var.docker_host.hostname}" {
  policy = "write"
}
RULE
}

resource "consul_acl_token" "nomad_client" {
  description = "Consul token for nomad client ${var.docker_host.hostname}"
  policies    = [consul_acl_policy.nomad_client.name]
  local       = true
}

data "consul_acl_token_secret_id" "nomad_client" {
  accessor_id = consul_acl_token.nomad_client.id
}