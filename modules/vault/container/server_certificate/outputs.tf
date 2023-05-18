output "private_key" {
  value = tls_private_key.server_cert.private_key_pem
}

output "public_key" {
  value = tls_locally_signed_cert.server_cert.cert_pem
}

output "full_chain" {
  value = join(
    "\n",
    [
      data.aws_s3_object.intermediate_full_chain.body,
      tls_locally_signed_cert.server_cert.cert_pem
    ]
  )
}