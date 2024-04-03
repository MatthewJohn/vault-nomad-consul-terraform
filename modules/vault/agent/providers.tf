terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://${var.docker_host.username}@${var.docker_host.fqdn}:22"

  alias = "vault"
}
