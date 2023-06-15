terraform {
  required_providers {
    freeipa = {
      version = "3.0.0"
      source  = "terraform-cache.dockstudios.co.uk/rework-space-com/freeipa"
    }
  }
}

provider "vault" {
  address      = "https://${var.setup_host}:8200"
  ca_cert_file = var.ca_cert_file
  token        = var.root_token
}
