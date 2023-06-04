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

