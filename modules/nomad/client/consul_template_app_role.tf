resource "vault_policy" "client_consul_template" {
  name = "nomad-client-${var.region.name}-${var.datacenter.name}-consul-template-${var.docker_host.hostname}"

  policy = <<EOF
# Access CA certs
path "${var.region.pki_mount_path}/issue/${var.datacenter.client_pki_role_name}" {
  capabilities = [ "read", "update" ]
}

# Generate token for nomad client using consul engine role
path "${var.consul_datacenter.consul_engine_mount_path}/creds/nomad-${var.region.name}-${var.datacenter.name}-client-*" {
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

# Access to harbor credentials
path "${module.harbor_account.secret_mount}/${module.harbor_account.secret_name}"
{
  capabilities = [ "read" ]
}
path "${module.harbor_account.secret_mount}/data/${module.harbor_account.secret_name}"
{
  capabilities = [ "read" ]
}

EOF
}

resource "vault_approle_auth_backend_role" "client_consul_template" {
  backend        = var.region.approle_mount_path
  role_name      = vault_policy.client_consul_template.name
  token_policies = [vault_policy.client_consul_template.name]
}

data "vault_approle_auth_backend_role_id" "consul_template" {
  backend   = var.region.approle_mount_path
  role_name = vault_approle_auth_backend_role.client_consul_template.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "consul_template" {
  backend   = var.region.approle_mount_path
  role_name = data.vault_approle_auth_backend_role_id.consul_template.role_name

  metadata = jsonencode(
    {
      "node_name"  = "nomad-client-${var.region.name}-${var.datacenter.name}-${var.docker_host.hostname}"
      "region"     = var.region.name
      "datacenter" = var.datacenter.name
      "hostname"   = var.docker_host.hostname
    }
  )
}
