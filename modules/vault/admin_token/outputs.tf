output "admin_policy" {
  description = "Name of admin policy"
  value       = vault_policy.admin.name
}

output "admin_token" {
  description = "Admin token"
  value       = vault_token.admin.client_token
}