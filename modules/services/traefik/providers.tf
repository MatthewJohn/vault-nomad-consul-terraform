provider "nomad" {
  address   = var.nomad_region.address
  region    = var.nomad_region.name
  secret_id = var.nomad_bootstrap.token
  ca_pem    = var.nomad_region.root_cert_public_key
}

provider "vault" {
  address      = var.vault_cluster.address
  ca_cert_file = var.vault_cluster.ca_cert_file
  token        = var.vault_cluster.token
}

provider "consul" {
  address    = var.consul_datacenter.address
  datacenter = var.consul_datacenter.name
  # @TODO Replace with more restrictive terraform token
  token      = var.consul_bootstrap.token
  ca_pem     = var.consul_datacenter.root_cert_public_key
}

terraform {
  required_providers {
    freeipa = {
      version = "3.0.0"
      source  = "terraform-cache.dockstudios.co.uk/rework-space-com/freeipa"
    }
  }
}
