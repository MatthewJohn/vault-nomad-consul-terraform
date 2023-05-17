terraform {
  required_providers {
    libvirt = {
      source = "github.com/matthewjohn/libvirt"
      #version = "0.7.1"
    }
    macaddress = {
      source = "ivoronin/macaddress"
      version = "0.3.2"
    }
  }
}
