
# Create policy for nomad server in consul
# and create vault consul_engine role to
# allow consul-template to generate a token
# during startup

resource "consul_acl_policy" "nomad_server" {
  name = "nomad-${var.region.name}-server-${var.docker_host.hostname}"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules = <<-RULE
# As per https://developer.hashicorp.com/nomad/docs/integrations/consul-integration
key_prefix "" {
  policy = "read"
}

agent_prefix "" {
  policy = "read"
}
node_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

agent "consul-client-${var.consul_datacenter.name}-${var.docker_host.hostname}" {
  policy = "write"
}

node "consul-client-${var.consul_datacenter.name}-${var.docker_host.hostname}" {
  policy = "write"
}

acl = "write"
mesh = "write"

RULE
}

resource "consul_acl_token" "nomad_server" {
  description = "Consul token for nomad server ${var.docker_host.hostname}"
  policies    = [consul_acl_policy.nomad_server.name]
  local       = true
}

data "consul_acl_token_secret_id" "nomad_server" {
  accessor_id = consul_acl_token.nomad_server.id
}