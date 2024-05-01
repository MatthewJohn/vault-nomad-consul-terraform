
resource "vault_policy" "consul_client_consul_template" {
  name = "consul-client-consul-template-${var.datacenter.name}-${var.docker_host.hostname}"

  policy = <<EOF
# Access CA certs
path "${var.datacenter.pki_mount_path}/issue/${var.datacenter.client_ca_role_name}" {
  capabilities = [ "read", "update" ]
}

# Access to static agent token
path "${module.consul_token.secret_mount}/${module.consul_token.secret_name}"
{
  capabilities = [ "read" ]
}
path "${module.consul_token.secret_mount}/data/${module.consul_token.secret_name}"
{
  capabilities = [ "read" ]
}

# Access to gossip token
path "${var.vault_cluster.consul_static_mount_path}/data/${var.datacenter.name}/gossip"
{
  capabilities = [ "read" ]
}
path "${var.vault_cluster.consul_static_mount_path}/${var.datacenter.name}/gossip"
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
path "${var.datacenter.approle_mount_path}/login"
{
  capabilities = ["update"]
}

EOF
}

resource "vault_approle_auth_backend_role" "consul_client_consul_template" {
  backend        = var.datacenter.approle_mount_path
  role_name      = "consul-client-${var.datacenter.name}-consul-template-${var.docker_host.hostname}"
  token_policies = [vault_policy.consul_client_consul_template.name]
}


data "vault_approle_auth_backend_role_id" "consul_template" {
  backend   = vault_approle_auth_backend_role.consul_client_consul_template.backend
  role_name = var.custom_role != null ? var.custom_role.approle_name : vault_approle_auth_backend_role.consul_client_consul_template.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "consul_template" {
  backend   = data.vault_approle_auth_backend_role_id.consul_template.backend
  role_name = data.vault_approle_auth_backend_role_id.consul_template.role_name

  metadata = jsonencode(
    {
      "node_name"  = "consul-client-${var.datacenter.name}-${var.docker_host.hostname}"
      "datacenter" = var.datacenter.name
    }
  )
}
