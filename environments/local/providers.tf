terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    libvirt = {
      source = "github.com/matthewjohn/libvirt"
      #version = "0.7.1"
    }
    freeipa = {
      version = "3.0.0"
      source  = "rework-space-com/freeipa"
    }
  }
}
