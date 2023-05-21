
output "name" {
  description = "Datacenter name"
  value       = var.datacenter
}

output "common_name" {
  description = "Common name"
  value       = local.common_name
}

output "role_name" {
  description = "Role name for certificate"
  value       = vault_pki_secret_backend_role.this.name
}

output "pki_mount_path" {
  description = "PKI path"
  value       = vault_mount.this.path
}

output "agent_ca_token" {
  description = "Token for agent to authenticate to vault"
  value       = vault_token.agent_ca.client_token
}

output "root_cert_public_key" {
  description = "Root cert public key"
  value       = var.root_cert.public_key
}

output "address" {
  description = "Endpoint for cluster"
  value       = "http://${local.common_name}:8500"
}
