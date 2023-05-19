output "private_key" {
  value = tls_private_key.server_cert.private_key_pem
}

output "public_key" {
  value = tls_locally_signed_cert.server_cert.cert_pem
}

output "full_chain" {
  value = join(
    "",
    [
      tls_locally_signed_cert.server_cert.cert_pem,
      data.aws_s3_object.intermediate_ca_bundle.body,
    ]
  )
}

output "root_ca_cert" {
  #value = data.aws_s3_object.intermediate_ca_bundle.body
  #value = data.aws_s3_object.intermediate_public_key.body
  value = data.aws_s3_object.root_ca_cert.body
}
