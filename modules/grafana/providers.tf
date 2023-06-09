terraform {
  required_providers {
    docker = {
      source  = "terraform-cache.dockstudios.co.uk/kreuzwerker/docker"
      version = "3.0.2"
    }
    freeipa = {
      version = "3.0.0"
      source  = "terraform-cache.dockstudios.co.uk/rework-space-com/freeipa"
    }
  }
}

provider "docker" {
  host = "ssh://${var.docker_username}@${var.docker_host}:22"
}
