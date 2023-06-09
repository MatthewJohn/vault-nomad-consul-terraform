
resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
  backend     = vault_mount.this.path
  type        = "internal"
  common_name = local.common_name

  alt_names = [
    local.nomad_verify_domain
  ]

  depends_on = [
    vault_mount.this
  ]
}

# Sign intermediate certificate with root cert
resource "vault_pki_secret_backend_root_sign_intermediate" "this" {
  backend = var.root_cert.pki_mount_path

  csr = vault_pki_secret_backend_intermediate_cert_request.this.csr

  ttl = "43800h"

  common_name  = local.common_name
  ou           = var.root_cert.ou
  organization = var.root_cert.organisation

  revoke = true
}

resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
  backend     = vault_mount.this.path
  certificate = join("\n", vault_pki_secret_backend_root_sign_intermediate.this.ca_chain)
}

resource "vault_pki_secret_backend_role" "this" {
  backend = vault_mount.this.path
  name    = "nomad-${var.region}"

  max_ttl          = (720 * 60 * 60) # "720h"
  generate_lease   = true
  allowed_domains  = [local.common_name, local.nomad_verify_domain]
  allow_subdomains = true

  depends_on = [
    vault_pki_secret_backend_intermediate_set_signed.this
  ]
}
