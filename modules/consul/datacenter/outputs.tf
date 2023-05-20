
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
