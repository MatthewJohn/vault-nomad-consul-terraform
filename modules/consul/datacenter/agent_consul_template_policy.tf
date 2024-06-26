
resource "vault_policy" "agent_consul_template" {
  name = "agent-consul-template-${var.datacenter}"

  policy = <<EOF
# Issue cert using datacenter PKI
path "${var.root_cert.pki_mount_path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
}

# Access vault static tokens
path "${var.vault_cluster.consul_static_mount_path}/data/${var.datacenter}/*"
{
  capabilities = [ "read" ]
}
path "${var.vault_cluster.consul_static_mount_path}/${var.datacenter}/*"
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

path "${vault_auth_backend.approle.path}/login"
{
  capabilities = ["update"]
}

# Allow reading CA chain for int PKI
path "${var.root_cert.pki_mount_path}/cert/ca_chain"
{
  capabilities = ["read"]
}

EOF
}

resource "vault_approle_auth_backend_role" "server_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "consul-server-${var.datacenter}-consul-template"
  token_policies = [vault_policy.agent_consul_template.name]
}
