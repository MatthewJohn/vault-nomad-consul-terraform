terraform {
  required_providers {
    vault = {
      configuration_aliases = [vault.vault-adm]
    }
  }
}