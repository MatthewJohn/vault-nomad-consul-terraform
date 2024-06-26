locals {
  common_name = "${var.datacenter}.${var.root_cert.common_name}"
}

# resource "vault_pki_secret_backend_intermediate_cert_request" "this" {
#   backend     = vault_mount.this.path
#   type        = "internal"
#   common_name = local.common_name

#   depends_on = [
#     vault_mount.this
#   ]
# }

# # Sign intermediate certificate with root cert
# resource "vault_pki_secret_backend_root_sign_intermediate" "this" {
#   backend = var.root_cert.pki_mount_path

#   csr = vault_pki_secret_backend_intermediate_cert_request.this.csr

#   ttl = "43800h"

#   common_name  = local.common_name
#   ou           = var.root_cert.ou
#   organization = var.root_cert.organisation

#   revoke = true
# }

# resource "vault_pki_secret_backend_intermediate_set_signed" "this" {
#   backend     = vault_mount.this.path
#   certificate = vault_pki_secret_backend_root_sign_intermediate.this.certificate_bundle
# }

# resource "vault_pki_secret_backend_config_issuers" "this" {
#   backend                       = vault_mount.this.path
#   default                       = vault_pki_secret_backend_intermediate_set_signed.this.imported_issuers
#   default_follows_latest_issuer = true
# }


resource "vault_pki_secret_backend_role" "this" {
  backend = var.root_cert.pki_mount_path
  name    = "consul-${var.datacenter}"

  max_ttl            = (720 * 60 * 60) # "720h"
  generate_lease     = true
  allowed_domains    = [local.common_name]
  allow_subdomains   = true
  allow_bare_domains = true

  # depends_on = [
  #   vault_pki_secret_backend_config_issuers.this
  # ]
}

resource "vault_pki_secret_backend_role" "client" {
  backend = var.root_cert.pki_mount_path
  name    = "consul-client-${var.datacenter}"

  max_ttl        = (720 * 60 * 60) # "720h"
  generate_lease = true
  allowed_domains = [
    "client.${local.common_name}",
    "localhost"
  ]
  # Allow client IP in certificate
  allow_ip_sans = true
  # Allow localhost in certificate for direct communication with client
  allow_localhost = true
  # Force use of client. domain
  allow_bare_domains = true
  allow_subdomains   = false

  # depends_on = [
  #   vault_pki_secret_backend_intermediate_set_signed.this
  # ]
}

# resource "vault_pki_secret_backend_config_urls" "this" {
#   backend = vault_mount.this.path

#   issuing_certificates = [
#     "${var.vault_cluster.address}/v1/${vault_mount.this.path}/ca",
#   ]

#   crl_distribution_points = [
#     "${var.vault_cluster.address}/v1/${vault_mount.this.path}/crl",
#   ]
# }

