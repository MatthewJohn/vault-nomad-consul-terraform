terraform {
  required_providers {
    docker = {
      source  = "terraform-cache.dockstudios.co.uk/kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://${var.docker_username}@${var.docker_host}:22"
}

provider "nomad" {
  address   = var.nomad_region.address
  region    = var.nomad_region.name
  secret_id = var.nomad_bootstrap.token
  ca_pem    = var.nomad_region.root_cert_public_key
}
