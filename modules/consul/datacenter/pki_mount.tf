resource "vault_mount" "this" {
  path        = "pki_consul_int"
  type        = "pki"
  description = "Consul CA Intermediate PKI"

  # 5 Years
  max_lease_ttl_seconds = (5 * 365 * 24 * 60 * 60)
}
