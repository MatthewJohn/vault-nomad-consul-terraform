resource "vault_mount" "this" {
  path        = "pki_${var.mount_name}"
  type        = "pki"
  description = "${var.description} PKI"

  # 10 Years
  max_lease_ttl_seconds = (10 * 365 * 24 * 60 * 60)
}
