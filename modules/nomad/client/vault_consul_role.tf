
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

node_prefix "consul-client-${var.consul_datacenter.name}-" {
  policy = "write"
}

agent "consul-client-${var.consul_datacenter.name}-${var.docker_host.hostname}" {
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

# Consul template for consul agent
resource "vault_policy" "consul_client_consul_template" {
  name = "consul-client-${var.consul_datacenter.name}-nomad-client-${var.region.name}-${var.datacenter.name}-consul-template-${var.docker_host.hostname}"

  policy = <<EOF
# Access CA certs
path "${var.root_cert.pki_mount_path}/issue/${var.consul_datacenter.client_ca_role_name}" {
  capabilities = [ "read", "update" ]
}

# Access to consul agent consul role to generate token
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.nomad_client_vault_consul_role.name}"
{
  capabilities = ["read"]
}

# Access to gossip token
path "${var.vault_cluster.consul_static_mount_path}/data/${var.consul_datacenter.name}/gossip"
{
  capabilities = [ "read" ]
}
path "${var.vault_cluster.consul_static_mount_path}/${var.consul_datacenter.name}/gossip"
{
  capabilities = [ "read" ]
}

# Renew leases
path "sys/leases/renew" {
  capabilities = [ "update" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

# @TODO What is this for?
path "${var.consul_datacenter.approle_mount_path}/login"
{
  capabilities = ["update"]
}

EOF
}

resource "vault_approle_auth_backend_role" "consul_client_consul_template" {
  backend        = var.consul_datacenter.approle_mount_path
  role_name      = "consul-client-${var.consul_datacenter.name}-nomad-client-${var.region.name}-${var.datacenter.name}-consul-template-${var.docker_host.hostname}"
  token_policies = [vault_policy.consul_client_consul_template.name]
}