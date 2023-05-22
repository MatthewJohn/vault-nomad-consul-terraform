
resource "vault_policy" "agent_consul_template" {
  name = "agent-consul-template-${var.datacenter}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
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

EOF
}
