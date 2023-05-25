
resource "vault_policy" "server_consul_template" {
  name = "nomad-server-consul-template-${var.datacenter}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
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

EOF
}

resource "vault_approle_auth_backend_role" "server_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nomad-server-${var.datacenter}-consul-template"
  token_policies = [vault_policy.server_consul_template.name]
}
