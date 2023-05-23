
resource "vault_mount" "connect_intermediate" {
  path        = "pki_int_connect_${var.datacenter}"
  type        = "pki"
  description = "Consul Connect CA ${var.datacenter} Intermediate PKI"

  # 5 Years
  max_lease_ttl_seconds = (5 * 365 * 24 * 60 * 60)
}

resource "vault_policy" "connect_ca" {
  name = "consul-connect-ca-${var.datacenter}"

  policy = <<EOF

path "/sys/mounts/${var.root_cert.pki_connect_mount_path}" {
  capabilities = [ "read" ]
}

path "/sys/mounts/${vault_mount.connect_intermediate.path}" {
  capabilities = [ "read" ]
}

path "/sys/mounts/${vault_mount.connect_intermediate.path}/tune" {
  capabilities = [ "update" ]
}

path "/${var.root_cert.pki_connect_mount_path}/" {
  capabilities = [ "read" ]
}

path "/${var.root_cert.pki_connect_mount_path}/root/sign-intermediate" {
  capabilities = [ "update" ]
}

path "/${vault_mount.connect_intermediate.path}/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "auth/token/lookup-self" {
  capabilities = [ "read" ]
}
EOF
}

resource "vault_approle_auth_backend_role" "connect_ca" {
  backend        = vault_auth_backend.approle.path
  role_name      = "consul-connect-ca-${var.datacenter}"
  token_policies = [vault_policy.connect_ca.name]
}

