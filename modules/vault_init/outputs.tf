output "root_token" {
  value = data.external.init_vault.result.root_token
}

output "ca_cert_file" {
  value = data.external.init_vault.result.ca_cert_file
}

output "vault_unseal_bucket" {
  value = aws_s3_bucket.vault_unseal.id
}

output "autoseal_token_file" {
  value = data.external.init_vault.result.autoseal_token_file
}
