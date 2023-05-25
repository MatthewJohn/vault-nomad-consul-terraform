resource "vault_mount" "pki_connect" {
  count = var.create_connect_ca == true ? 1 : 0

  path        = "pki_connect"
  type        = "pki"
  description = "Consul Connect CA PKI"

  # 10 Years
  max_lease_ttl_seconds = (10 * 365 * 24 * 60 * 60)
}

# resource "vault_pki_secret_backend_root_cert" "test" {
#   backend               = vault_mount.pki.path
#   type                  = "internal"
#   common_name           = "Consul Connect CA"

#   # 10 years
#   ttl                   = (10 * 365 * 24 * 60 * 60)

#   format                = "pem"
#   private_key_format    = "der"
#   key_type              = "rsa"
#   key_bits              = 4096

#   ou                    = var.ou
#   organization          = var.organisation

#   depends_on            = [
#     vault_mount.pki_connect
#   ]
# }
