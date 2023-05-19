provider "vault" {
  url          = "https://${var.vault_host}:8200"
  token        = var.root_token
  ca_cert_file = var.ca_cert_file
}
