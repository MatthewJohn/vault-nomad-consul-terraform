
resource "vault_policy" "client_consul_template" {
  name = "nomad-client-${var.region.name}-${var.datacenter}-consul-template"

  policy = <<EOF
# Access CA certs
path "${var.region.pki_mount_path}/issue/${vault_pki_secret_backend_role.client.name}" {
  capabilities = [ "read", "update" ]
}

# Generate token for nomad client using consul engine role
path "${var.consul_datacenter.consul_engine_mount_path}/creds/nomad-${var.region.name}-${var.datacenter}-client-*" {
  capabilities = ["read"]
}

# Renew leases
path "sys/leases/renew" {
  capabilities = [ "update" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "${var.region.approle_mount_path}/login"
{
  capabilities = ["update"]
}

# Allow access to read root CA
path "${var.root_cert.pki_mount_path}/cert/ca"
{
  capabilities = ["read"]
}

# Allow access to read region CA
path "${var.region.pki_mount_path}/cert/ca"
{
  capabilities = ["read"]
}

# Access to harbor account
path "${module.harbor_account.secret_mount}/${module.harbor_account.secret_name}"
{
  capabilities = ["read"]
}
path "${module.harbor_account.secret_mount}/data/${module.harbor_account.secret_name}"
{
  capabilities = ["read"]
}

EOF
}

resource "vault_approle_auth_backend_role" "client_consul_template" {
  backend        = var.region.approle_mount_path
  role_name      = "nomad-client-${var.region.name}-${var.datacenter}-consul-template"
  token_policies = [vault_policy.client_consul_template.name]
}
