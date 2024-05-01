output "secret_name" {
  description = "Vault secret name for token"
  value       = vault_kv_secret_v2.this.name
}

output "secret_mount" {
  description = "Vault KV mount for token"
  value       = vault_kv_secret_v2.this.mount
}