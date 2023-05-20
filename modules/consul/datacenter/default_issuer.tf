# Hack around setting default issuers

data "http" "get_current_issuer"

data "vault_generic_secret" "pki_default_issuer" {
  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.this
  ]

  path = "${var.root_cert.pki_mount_path}/config/issuers"
}
# Set default_follows_latest_issuer
resource "vault_generic_endpoint" "pki_config_issuers" {
  path = "${vault_mount.this.path}/config/issuers"

  data_json = jsonencode({
    default                       = data.vault_generic_secret.pki_default_issuer.data.default,
    default_follows_latest_issuer = true,
  })
  disable_delete = true
}