
resource "vault_policy" "client_consul_template" {
  name = "nomad-client-consul-template-${var.region}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.client.name}" {
  capabilities = [ "read", "update" ]
}

# Generate token for nomad client using consul engine role
path "${var.consul_datacenter.consul_engine_mount_path}/creds/nomad-${var.region}-client-*" {
  capabilities = ["read"]
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

resource "vault_approle_auth_backend_role" "client_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nomad-client-${var.region}-consul-template"
  token_policies = [vault_policy.client_consul_template.name]
}
