resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
  subject {
    common_name         = local.common_name
    organization        = var.organisation
    organizational_unit = var.ou
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
  backend = vault_mount.this.path
  pem_bundle = join("", [
    tls_self_signed_cert.this.cert_pem,
    tls_private_key.this.private_key_pem
  ])

  depends_on = [
    vault_mount.this,
    tls_private_key.this
  ]
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.this.path

  issuing_certificates = [
    "${var.vault_cluster.address}/v1/${vault_mount.this.path}/ca",
  ]

  crl_distribution_points = [
    "${var.vault_cluster.address}/v1/${vault_mount.this.path}/crl",
  ]
}

resource "vault_pki_secret_backend_role" "role" {
  backend = vault_mount.this.path
  name    = local.common_name

  key_type = "rsa"
  key_bits = 4096
  allowed_domains = [
    local.common_name
  ]
  allow_subdomains = true
}
