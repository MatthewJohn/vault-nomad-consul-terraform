resource "vault_kv_secret_v2" "consul_token" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "${var.consul_datacenter.name}/nomad/client/${var.region.name}/${var.datacenter.name}/${var.docker_host.hostname}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = data.consul_acl_token_secret_id.nomad_client.secret_id
    }
  )
}

resource "vault_policy" "consul_template" {
  name = "nomad-client-consul-template-${var.region.name}-${var.datacenter.name}-${var.docker_host.hostname}"

  policy = <<EOF
# Access CA certs
path "${var.region.pki_mount_path}/issue/${var.datacenter.client_pki_role_name}" {
  capabilities = [ "read", "update" ]
}

# Obtain static consul tokens
path "${vault_kv_secret_v2.consul_token.mount}/metadata/${vault_kv_secret_v2.consul_token.name}" {
  capabilities = ["read"]
}
path "${vault_kv_secret_v2.consul_token.mount}/data/${vault_kv_secret_v2.consul_token.name}" {
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
path "${var.datacenter.harbor_account.secret_mount}/${var.datacenter.harbor_account.secret_name}"
{
  capabilities = ["read"]
}
path "${var.datacenter.harbor_account.secret_mount}/data/${var.datacenter.harbor_account.secret_name}"
{
  capabilities = ["read"]
}
EOF

  depends_on = [
    vault_kv_secret_v2.consul_token
  ]
}

resource "vault_approle_auth_backend_role" "consul_template" {
  backend        = var.region.approle_mount_path
  role_name      = "nomad-client-${var.region.name}-${var.datacenter.name}-${var.docker_host.hostname}-consul-template"
  token_policies = [vault_policy.consul_template.name]
}

data "vault_approle_auth_backend_role_id" "consul_template" {
  backend   = vault_approle_auth_backend_role.consul_template.backend
  role_name = vault_approle_auth_backend_role.consul_template.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "consul_template" {
  backend   = data.vault_approle_auth_backend_role_id.consul_template.backend
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
