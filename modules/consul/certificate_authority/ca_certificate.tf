# resource "vault_pki_secret_backend_root_cert" "this" {
#   backend = vault_mount.consul_pki.path

#   type = "internal"

#   common_name  = var.common_name
#   ou           = var.ou
#   organization = var.organisation

#   key_bits = 4096

#   depends_on = [
#     vault_mount.consul_pki
#   ]
# }

resource "tls_private_key" "this" {
  algorithm   = "RSA"
  rsa_bits  = 4096
  #ecdsa_curve = var.ecdsa_curve
}


resource "tls_self_signed_cert" "this" {
   private_key_pem = tls_private_key.this.private_key_pem
   subject {
     common_name = var.common_name
     organization = var.organisation
     organizational_unit = var.ou
    #  street_address = ["1234 Main Street"]
    #  locality = "Beverly Hills"
    #  province = "CA"
    #  country = "USA"
    #  postal_code = "90210"

   }
   # 175200 = 20 years
   validity_period_hours = 175200
   allowed_uses = [
     "cert_signing",
     "crl_signing"
   ]
   is_ca_certificate = true 
}

resource "vault_pki_secret_backend_config_ca" "ca_config" {
  backend  = vault_mount.consul_pki.path
  pem_bundle = tls_self_signed_cert.this.cert_pem

  depends_on = [
    vault_mount.consul_pki,
    tls_private_key.this
  ]
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.consul_pki.path

  issuing_certificates = [
    "${var.vault_cluster.address}/v1/${vault_mount.consul_pki.path}/ca",
  ]

  crl_distribution_points = [
    "${var.vault_cluster.address}/v1/${vault_mount.consul_pki.path}/crl",
  ]
}
