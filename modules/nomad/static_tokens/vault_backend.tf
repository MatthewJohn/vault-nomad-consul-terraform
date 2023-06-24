
# Vault secret backend for nomad to allow authentication via
# vault
resource "vault_nomad_secret_backend" "this" {
  backend                   = "nomad-${var.region.name}"
  description               = "Manages the Nomad backend for ${var.region.name}"
  default_lease_ttl_seconds = "3600"
  max_lease_ttl_seconds     = "7200"
  max_ttl                   = "240"
  address                   = var.region.address
  token                     = var.bootstrap.token
  ca_cert                   = var.root_cert.public_key
  ttl                       = "120"
}
