
resource "vault_policy" "agent_consul_template" {
  name = "agent-consul-template-${var.datacenter}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
}

# Access to consul agent consul role to generate token
path "${local.consul_engine_mount_path}/creds/consul-server-role"
{
  capabilities = ["read"]
}

# Access vault static tokens
path "${var.vault_cluster.consul_static_mount_path}/data/${var.datacenter}/agent-tokens/*"
{
  capabilities = [ "read" ]
}
path "${var.vault_cluster.consul_static_mount_path}/${var.datacenter}/agent-tokens/*"
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

path "approle-consul-dc1/login"
{
  capabilities = ["update"]
}

EOF
}

resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle-consul-${var.datacenter}"
}

resource "vault_approle_auth_backend_role" "server_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "consul-server-${var.datacenter}-consul-template"
  token_policies = [vault_policy.agent_consul_template.name]
}
