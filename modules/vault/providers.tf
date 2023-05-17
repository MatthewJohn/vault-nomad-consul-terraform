terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://docker-connect@vault-1.dock.local:22"

  alias = "vault1"
}
