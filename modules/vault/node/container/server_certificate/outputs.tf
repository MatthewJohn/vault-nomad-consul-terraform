output "private_key" {
  value = vault_pki_secret_backend_cert.server_cert.private_key
}

output "public_key" {
  value = vault_pki_secret_backend_cert.server_cert.certificate
}

output "full_chain" {
  value = join(
    "\n",
    [
      vault_pki_secret_backend_cert.server_cert.certificate,
      vault_pki_secret_backend_cert.server_cert.ca_chain,
    ]
  )
}

output "root_ca_cert" {
  value = vault_pki_secret_backend_cert.server_cert.issuing_ca
}
