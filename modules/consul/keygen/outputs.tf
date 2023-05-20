output "secret" {
  description = "Base64 secret value"
  value       = random_id.key.b64_std
  sensitive   = true
}