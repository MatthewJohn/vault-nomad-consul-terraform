
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

agent "consul-client-${var.consul_datacenter.name}-${var.docker_host.hostname}" {
  policy = "write"
}

# Hopefully not required as servers have this permission
#acl = "write"


service "nomad-${var.region.name}-${var.datacenter.name}-client" {
  policy = "write"
}

service "nomad-${var.region.name}-client" {
  policy = "write"
}

RULE
}

resource "vault_consul_secret_backend_role" "nomad_client_vault_consul_role" {
  name    = "nomad-${var.region.name}-${var.datacenter.name}-client-${var.docker_host.hostname}"
  backend = var.consul_datacenter.consul_engine_mount_path

  local = true

  # Max 1 day TTL
  ttl     = 60 * 60 * 24
  max_ttl = 60 * 60 * 24

  consul_policies = [
    consul_acl_policy.nomad_client.name
  ]
}