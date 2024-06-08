provider "consul" {
  address    = var.datacenter.address
  datacenter = var.datacenter.name
  token      = var.bootstrap.token
  ca_pem     = var.datacenter.root_cert_public_key
}
