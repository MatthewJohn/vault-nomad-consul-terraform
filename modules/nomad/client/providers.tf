terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://${var.docker_username}@${var.docker_host}:22"

  alias = "consul"
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
  token  = var.consul_bootstrap.token
  ca_pem = var.consul_datacenter.root_cert_public_key
}

