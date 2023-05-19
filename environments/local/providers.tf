terraform {
  required_providers {
    docker = {
      source  = "terraform-cache.dockstudios.co.uk/kreuzwerker/docker"
      version = "3.0.2"
    }
    libvirt = {
      source = "terraform-cache.dockstudios.co.uk/dockstudios-terraform/libvirt"
      version = "1.0.0"
    }
    freeipa = {
      version = "3.0.0"
      source  = "terraform-cache.dockstudios.co.uk/rework-space-com/freeipa"
    }
  }
}

provider "docker" {
  alias = "local"
}

provider "freeipa" {
  host     = "freeipa.dock.local"
  username = local.freeipa_admin
  password = local.freeipa_password
  insecure = true
}

provider "libvirt" {
  uri = "qemu:///system"

  alias = "vm_host"
}

