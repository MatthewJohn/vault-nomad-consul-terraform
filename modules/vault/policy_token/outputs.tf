output "policy_name" {
  description = "Name of policy"
  value       = vault_policy.this.name
}

output "token" {
  description = "Token value"
  value       = vault_token.this.client_token
}