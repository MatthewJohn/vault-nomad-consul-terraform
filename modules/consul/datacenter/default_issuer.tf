# Hack around setting default issuers

data "external" "get_current_issuer" {
  program = [
    "curl",
    "--fail",
    "-s",
    "-H", "X-Vault-Token: ${var.vault_cluster.token}",
    "--cacert", var.vault_cluster.ca_cert_file,
    "-XLIST",
    "${var.vault_cluster.address}/v1/${vault_mount.this.path}/issuers"
  ]

  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.this
  ]
}

# Set default_follows_latest_issuer
resource "vault_generic_endpoint" "pki_config_issuers" {
  path = "${vault_mount.this.path}/config/issuers"

  data_json = jsonencode({
    default                       = data.external.get_current_issuer.result.keys[0],
    default_follows_latest_issuer = true,
  })
  disable_delete = true

  lifecycle {
    ignore_changes = [
        data_json
    ]
  }
}