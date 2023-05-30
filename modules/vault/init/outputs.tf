output "root_token" {
  description = "Vault root token"
  value       = data.external.init_vault.result.root_token
}

output "ca_cert_file" {
  description = "CA Cert file path"
  value       = data.external.init_vault.result.ca_cert_file
}

output "ca_cert" {
  description = "CA Cert file content"
  value       = data.external.init_vault.result.ca_cert_file
}

output "vault_unseal_bucket" {
  description = "Bucket storing vault unseal file"
  value       = aws_s3_bucket.vault_unseal.id
}
