output "pki_mount_path" {
  description = "PKI path"
  value       = vault_mount.consul_pki.path
}

output "common_name" {
  description = "Common name"
  value       = var.common_name
}

output "organisation" {
  description = "Certificate organisation"
  value       = var.organisation
}

output "ou" {
  description = "Certificate OU"
  value       = var.ou
}

output "public_key" {
  description = "Public key for root CA"
  value       = tls_self_signed_cert.this.cert_pem
}

output "issuer" {
  description = "Certificate Issuer"
  value       = vault_pki_secret_backend_role.role.name
}
