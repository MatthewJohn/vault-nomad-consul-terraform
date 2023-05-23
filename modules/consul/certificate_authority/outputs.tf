output "pki_mount_path" {
  description = "PKI path"
  value       = vault_mount.consul_pki.path
}

output "pki_connect_mount_path" {
  description = "PKI Connect path"
  value       = vault_mount.pki_connect.path
}

output "domain_name" {
  description = "Root domain name"
  value       = var.domain_name
}

output "consul_subdomain" {
  description = "Consul subdomain of domain name for CA"
  value       = var.consul_subdomain
}

output "common_name" {
  description = "Common name"
  value       = local.common_name
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
