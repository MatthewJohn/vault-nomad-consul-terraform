module "vault_image" {
  source = "./image"

  vault_version = var.vault_version

  providers = {
    docker = docker.vault
  }
}

module "vault_container" {
  source = "./container"

  image           = module.vault_image.image_id
  hostname        = var.hostname
  domain_name     = var.domain_name
  docker_ip       = var.docker_ip
  vault_subdomain = var.vault_subdomain
  all_vault_hosts = var.all_vault_hosts
  initial_primary = var.initial_primary

  docker_host     = var.docker_host
  docker_username = var.docker_username

  providers = {
    docker = docker.vault
  }

  depends_on = [
    module.vault_image
  ]
}
