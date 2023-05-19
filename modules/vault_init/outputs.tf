output "root_token" {
  value = data.external.init_vault.result.root_token
}

output "ca_cert_file" {
  value = data.external.init_vault.result.ca_cert_file
}
