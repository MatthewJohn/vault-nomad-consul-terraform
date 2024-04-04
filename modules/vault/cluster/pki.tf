resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "Vault root CA"

  # 20 years
  max_lease_ttl_seconds = (20 * 365 * 24 * 60 * 60)
}


resource "vault_pki_secret_backend_intermediate_cert_request" "root_ca" {
  depends_on  = [vault_mount.pki]
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "svc.${var.domain_name}"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "root_ca" {
  backend              = "pki"

  csr                  = vault_pki_secret_backend_intermediate_cert_request.root_ca.csr
  common_name          = "DockStudios SVC Intermediate CA"
  exclude_cn_from_sans = true
  ou                   = "SVC"
  organization         = "Dock Studios Ltd"
  country              = "GB"
  locality             = "United Kingdom"
  province             = "Hampshire"
  revoke               = true

  provider = vault.vault-adm
}

resource "vault_pki_secret_backend_intermediate_set_signed" "root_ca" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_ca.certificate_bundle
}

resource "vault_pki_secret_backend_config_urls" "pki" {
  backend = vault_mount.pki.path

  issuing_certificates = [
    "${local.cluster_address}/v1/${vault_mount.pki.path}/ca",
  ]

  crl_distribution_points = [
    "${local.cluster_address}/v1/${vault_mount.pki.path}/crl",
  ]
}

resource "vault_pki_secret_backend_config_issuers" "pki" {
  backend                       = vault_mount.pki.path
  default                       = vault_pki_secret_backend_intermediate_set_signed.root_ca.imported_issuers[0]
  default_follows_latest_issuer = true
}

# # Hack aroudn setting default issuers
# data "vault_generic_secret" "pki_default_issuer" {
#   depends_on = [
#     vault_pki_secret_backend_intermediate_set_signed.root_ca
#   ]

#   path = "${vault_mount.pki.path}/config/issuers"
# }
# # Set default_follows_latest_issuer
# resource "vault_generic_endpoint" "pki_config_issuers" {
#   path = "${vault_mount.pki.path}/config/issuers"

#   data_json = jsonencode({
#     default                       = data.vault_generic_secret.pki_default_issuer.data.default,
#     default_follows_latest_issuer = true,
#   })
#   disable_delete = true
# }
