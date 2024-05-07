resource "vault_kv_secret_v2" "consul_token" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "${var.consul_datacenter.name}/nomad/server/${var.region.name}/${var.docker_host.hostname}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = data.consul_acl_token_secret_id.nomad_server.secret_id
    }
  )
}

resource "vault_policy" "server_consul_template" {
  name = "nomad-server-consul-template-${var.region.name}-${var.docker_host.hostname}"

  policy = <<EOF
# Issue certificate
path "${var.region.pki_mount_path}/issue/${var.region.role_name}" {
  capabilities = [ "read", "update" ]
}
# Allow access to read root CA
path "${var.region.pki_mount_path}/cert/ca_chain"
{
  capabilities = ["read"]
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

# path "${var.region.approle_mount_path}/login"
# {
#   capabilities = ["update"]
# }

EOF

  depends_on = [
    vault_kv_secret_v2.consul_token
  ]
}

resource "vault_approle_auth_backend_role" "server_consul_template" {
  backend        = var.region.approle_mount_path
  role_name      = "nomad-server-${var.region.name}-${var.docker_host.hostname}-consul-template"
  token_policies = [vault_policy.server_consul_template.name]
}


data "vault_approle_auth_backend_role_id" "consul_template" {
  backend   = vault_approle_auth_backend_role.server_consul_template.backend
  role_name = vault_approle_auth_backend_role.server_consul_template.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "consul_template" {
  backend   = data.vault_approle_auth_backend_role_id.consul_template.backend
  role_name = data.vault_approle_auth_backend_role_id.consul_template.role_name

  metadata = jsonencode(
    {
      "node_name" = "nomad-server-${var.region.name}-${var.docker_host.hostname}"
      "region"    = var.region.name
    }
  )
}
