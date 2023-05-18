# We need to create a key for the intermediate cert
resource "tls_private_key" "vault_int" {
  algorithm   = var.key_algorithm
  ecdsa_curve = var.ecdsa_curve
}

# Once we have the key we can create a request
resource "tls_cert_request" "vault_int" {
  private_key_pem = tls_private_key.vault_int.private_key_pem

  # the wildcard here does not have an impact but will help remind that this
  # is an intermediate signing all *.rulz.xyz certificates
  subject {
    common_name = "vault.${var.root_cn}"
  }
}

# Sign vault intetermediate certificate 
resource "tls_locally_signed_cert" "vault_int" {
  cert_request_pem   = tls_cert_request.vault_int.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem
  is_ca_certificate  = true

  validity_period_hours = 8760 # One year of validity

  allowed_uses = [
    "cert_signing",
  ]
}

# Upload public/private intermediate keys to s3
resource "aws_s3_bucket_object" "intermediate_public_cert" {
  bucket       = aws_s3_bucket.intermediate_ca_certs.bucket
  key          = "vault/intermediate-1.crt"
  content      = tls_locally_signed_cert.vault_int.cert_pem
  content_type = "text/plain"
}
resource "aws_s3_bucket_object" "intermediate_full_chain" {
  bucket       = aws_s3_bucket.intermediate_ca_certs.bucket
  key          = "vault/intermediate-1-full-chain.crt"
  content      = join("\n", [
    tls_locally_signed_cert.vault_int.cert_pem,
    tls_self_signed_cert.root.cert_pem,
  ])
  content_type = "text/plain"
}
resource "aws_s3_bucket_object" "intermediate_private_key" {
  bucket       = aws_s3_bucket.intermediate_ca_certs.bucket
  key          = "vault/intermediate-1.key"
  content      = tls_private_key.vault_int.private_key_pem
  content_type = "text/plain"
}
