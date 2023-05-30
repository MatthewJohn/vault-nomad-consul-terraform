resource "vault_mount" "this" {
  path        = "pki_int_nomad_${var.region}"
  type        = "pki"
  description = "Nomad CA ${var.region} Intermediate PKI"

  # 5 Years
  max_lease_ttl_seconds = (5 * 365 * 24 * 60 * 60)
}
