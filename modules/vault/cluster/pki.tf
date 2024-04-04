# Obtain certificate from vault-adm
# resource "vault_pki_secret_backend_cert" "ca_cert" {
#   backend = "pki"
#   name    = var.domain_name

#   common_name = "svc.${var.domain_name}"

#   revoke = true

#   format = "pem"
#   private_key_format = "der"

#   auto_renew = true

#   # 19 years - need to adjust as root CA expires
#   ttl = 19 * 365 * 24 * 60 * 60

#   provider = vault.vault-adm
# }

# resource "vault_pki_secret_backend_config_ca" "ca_config" {
#   backend = vault_mount.this.path
#   pem_bundle = join("\n", [
#     vault_pki_secret_backend_cert.ca_cert.certificate,
#     vault_pki_secret_backend_cert.ca_cert.ca_chain,
#     vault_pki_secret_backend_cert.ca_cert.private_key
#   ])

#   depends_on = [
#     vault_mount.this
#   ]
# }

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
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_ca.certificate
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

# resource "vault_pki_secret_backend_role" "role" {
#   backend = vault_mount.pki.path
#   name    = var.root_cert.root_domain

#   key_type = "rsa"
#   key_bits = 4096
#   allowed_domains = [
#     var.root_cert.root_domain
#   ]
#   allow_subdomains = true
# }
