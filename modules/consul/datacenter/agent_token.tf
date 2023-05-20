
resource "vault_policy" "agent_ca" {
  name = "consul-cert-${var.datacenter}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
}

# Renew leases
path "sys/leases/renew" {
  capabilities = [ "update" ]
}
EOF
}

resource "vault_token" "agent_ca" {
  policies = [vault_policy.agent_ca.name]

  metadata = {
    "purpose" = "Consul Certs ${var.datacenter}"
  }
}
