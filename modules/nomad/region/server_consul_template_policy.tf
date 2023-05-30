
resource "vault_policy" "server_consul_template" {
  name = "nomad-server-consul-template-${var.region}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
}

# Generate token for nomad server using consul engine role
path "${var.consul_datacenter.consul_engine_mount_path}/creds/nomad-${var.region}-server-*" {
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

# Allow access to read root CA
path "${var.root_cert.pki_mount_path}/cert/ca"
{
  capabilities = ["read"]
}

EOF
}

resource "vault_approle_auth_backend_role" "server_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nomad-server-${var.region}-consul-template"
  token_policies = [vault_policy.server_consul_template.name]
}
