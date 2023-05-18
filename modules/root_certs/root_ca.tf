resource "tls_private_key" "root" {
  algorithm   = var.key_algorithm
  ecdsa_curve = var.ecdsa_curve
}

# Here is our root certificate, using our private key previously created
resource "tls_self_signed_cert" "root" {
  private_key_pem   = tls_private_key.root.private_key_pem # we use our private key
  is_ca_certificate = true                                 # this is a certificate authority

  subject {
    common_name  = var.root_cn
    organization = var.organisation
  }

  # 100 Years
  validity_period_hours = 876000

  allowed_uses = [
    # Allow this certificate able to sign child certificates
    "cert_signing"
  ]
}

# Upload public key to s3
resource "aws_s3_object" "root_ca_cert" {
  bucket  = aws_s3_bucket.root_ca_certs.bucket
  key     = "vault/root_ca.crt"
  content = tls_self_signed_cert.root.cert_pem
}
