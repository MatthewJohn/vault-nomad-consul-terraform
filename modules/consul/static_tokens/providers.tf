provider "vault" {
  address      = var.vault_cluster.address
  ca_cert_file = var.vault_cluster.ca_cert_file
  token        = var.vault_cluster.token
}

provider "consul" {
  address    = var.datacenter.address
  datacenter = var.datacenter.name
  token      = var.bootstrap.token
  ca_pem     = var.datacenter.root_cert_public_key
}
