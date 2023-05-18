module "vault-1-image" {
  source = "./image"

  vault_version = var.vault_version

  providers = {
    docker = docker.vault1
  }
}

module "vault-1-container" {
  source = "./container"

  image = module.vault-1-image.image_id
  hostname = "vault-1"
  domain_name = var.domain_name

  docker_host     = "vault-1.dock.local"
  docker_username = "docker-connect"

  providers = {
    docker = docker.vault1
  }

  depends_on = [
    module.vault-1-image
  ]
}
