provider "nomad" {
  address   = var.nomad_region.address
  region    = var.nomad_region.name
  secret_id = var.nomad_bootstrap.token
  ca_pem    = var.nomad_region.root_cert_public_key
}
