locals {
  common_name = "${var.datacenter}.${var.root_cert.common_name}"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend     = vault_mount.this.path
  type        = "internal"
  common_name = local.common_name

  depends_on = [
    vault_mount.this
  ]
}

# Sign intermediate certificate with root cert
resource "vault_pki_secret_backend_root_sign_intermediate" "this" {
  backend = var.root_cert.pki_mount_path

  csr = vault_pki_secret_backend_intermediate_cert_request.this.csr

  common_name  = local.common_name
  ou           = var.root_cert.ou
  organization = var.root_cert.organisation

  revoke = true
}
