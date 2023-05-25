resource "vault_mount" "this" {
  path        = "pki_int_nomad_${var.datacenter}"
  type        = "pki"
  description = "Nomad CA ${var.datacenter} Intermediate PKI"

  # 5 Years
  max_lease_ttl_seconds = (5 * 365 * 24 * 60 * 60)
}
