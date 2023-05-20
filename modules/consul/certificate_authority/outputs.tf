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
