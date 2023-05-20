resource "vault_mount" "consul_pki" {
  path        = "pki_consul"
  type        = "pki"
  description = "Consul CA PKI"

  # 10 Years
  max_lease_ttl_seconds = (10 * 365 * 24 * 60 * 60)
}
