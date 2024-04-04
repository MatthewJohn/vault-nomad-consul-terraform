resource "vault_mount" "pki_connect" {
  count = var.create_connect_ca == true ? 1 : 0

  path        = "pki_connect"
  type        = "pki"
  description = "Consul Connect CA PKI"

  # 20 Years
  max_lease_ttl_seconds = (20 * 365 * 24 * 60 * 60)
}
