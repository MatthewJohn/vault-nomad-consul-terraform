
# Create policy for nomad client in consul
# and create vault consul_engine role to
# allow consul-template to generate a token
# during startup

resource "consul_acl_policy" "nomad_client" {
  name        = "nomad-${var.region.name}-client-${var.hostname}"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules       = <<-RULE
# As per https://developer.hashicorp.com/nomad/docs/integrations/consul-integration
key_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "write"
}

agent "consul-client-${var.consul_datacenter.name}-${var.hostname}" {
  policy = "read"
}

RULE
}

resource "vault_consul_secret_backend_role" "nomad_client_vault_consul_role" {
  name    = "nomad-${var.region.name}-client-${var.hostname}"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.nomad_client.name
  ]
}