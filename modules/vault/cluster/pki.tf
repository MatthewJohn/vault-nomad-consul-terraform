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
  certificate = join("\n", concat(
    [vault_pki_secret_backend_root_sign_intermediate.root_ca.certificate],
    vault_pki_secret_backend_root_sign_intermediate.root_ca.ca_chain
  ))
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

resource "vault_pki_secret_backend_config_issuers" "config" {
  backend                       = vault_mount.pki.path
  default                       = "30f7f2f2-2dd9-efa3-d3f7-abb08e9249a3"
  default_follows_latest_issuer = true

  lifecycle {
    ignore_changes = [ default ]
  }
}