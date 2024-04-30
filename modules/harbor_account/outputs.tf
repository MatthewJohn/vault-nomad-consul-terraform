output "secret_mount" {
  description = "Secret mount path"
  value       = vault_kv_secret_v2.this.mount
}

output "secret_name" {
  description = "Secret mount name"
  value       = vault_kv_secret_v2.this.name
}