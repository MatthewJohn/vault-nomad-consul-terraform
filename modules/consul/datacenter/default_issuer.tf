# Hack around setting default issuers

data "http" "get_current_issuer" {
  url = "${var.vault_cluster.address}/v1/${vault_mount.this.path}/issuers"

  request_headers = {
    Accept = "application/json"
    "X-Vault-Token" = var.vault_cluster.token
  }

  method = "LIST"

  insecure = true
}

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
    default                       = jsondecode(data.http.get_current_issuer.response_body)["data"]["keys"][0],
    default_follows_latest_issuer = true,
  })
  disable_delete = true

  lifecycle {
    ignore_changes = [
        data_json
    ]
  }
}