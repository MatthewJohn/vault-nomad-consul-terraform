resource "tls_private_key" "server_cert" {
  algorithm   = var.key_algorithm
  ecdsa_curve = var.ecdsa_curve
}

# Once we have the key we can create a request
resource "tls_cert_request" "server_cert" {
  private_key_pem = tls_private_key.server_cert.private_key_pem

  # the wildcard here does not have an impact but will help remind that this
  # is an intermediate signing all *.rulz.xyz certificates
  subject {
    common_name  = "${var.hostname}.${var.vault_domain}"
  }
}

# Sign vault intetermediate certificate 
resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.server_cert.cert_request_pem
  ca_private_key_pem = data.aws_s3_object.intermediate_private_key.body
  ca_cert_pem        = data.aws_s3_object.intermediate_public_key.body

  validity_period_hours = 8760 # One year of validity

  allowed_uses = [
    "cert_signing",
  ]

  # Ignore CA certs, due to whitespace changes
  lifecycle {
    ignore_changes = [
      ca_cert_pem,
      ca_private_key_pem
    ] 
  }

  # Trigger on change to MD5 hash change of s3 file contents
  depends_on = [
    null_resource.ssl_trigger
  ]
}
