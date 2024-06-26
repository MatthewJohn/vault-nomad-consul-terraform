
resource "vault_policy" "consul_client_consul_template" {
  name = "consul-client-consul-template-${var.datacenter}"

  policy = <<EOF
# Access CA certs
path "${var.root_cert.pki_mount_path}/issue/${vault_pki_secret_backend_role.client.name}" {
  capabilities = [ "read", "update" ]
}

# Access to consul agent consul role to generate token
path "${local.consul_engine_mount_path}/creds/consul-client-role"
{
  capabilities = ["read"]
}

# Access to gossip token
path "${var.vault_cluster.consul_static_mount_path}/data/${var.datacenter}/gossip"
{
  capabilities = [ "read" ]
}
path "${var.vault_cluster.consul_static_mount_path}/${var.datacenter}/gossip"
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
path "${vault_auth_backend.approle.path}/login"
{
  capabilities = ["update"]
}

EOF
}

resource "vault_approle_auth_backend_role" "consul_client_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "consul-client-${var.datacenter}-consul-template"
  token_policies = [vault_policy.consul_client_consul_template.name]
}
