output "pki_mount_path" {
  description = "PKI path"
  value       = var.vault_cluster.pki_mount_path
}

output "pki_connect_mount_path" {
  description = "PKI Connect path"
  value       = var.vault_cluster.pki_mount_path
}

output "domain_name" {
  description = "Root domain name"
  value       = var.domain_name
}

output "subdomain" {
  description = "Subdomain of domain name for CA"
  value       = var.subdomain
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
  value       = var.root_ca_cert
}

output "issuer" {
  description = "Certificate Issuer"
  value       = vault_pki_secret_backend_role.role.name
}
