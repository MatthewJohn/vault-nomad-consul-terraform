terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    vault = {
      configuration_aliases = [vault.vault-adm]
    }
  }
}