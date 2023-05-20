provider "vault" {
  address      = var.vault_cluster.address
  ca_cert_file = var.vault_cluster.ca_cert_file
  token        = var.vault_cluster.admin_token
}
