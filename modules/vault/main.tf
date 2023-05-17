module "vault-1-container" {
  source = "./container"

  vault_version = var.vault_version
  hostname = "vault-1"
  domain_name = var.domain_name

  providers = {
    docker = docker.vault1
  }
}
