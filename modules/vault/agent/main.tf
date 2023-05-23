module "image" {
  source = "./image"

  vault_version = var.vault_version
  image_name    = var.container_name

  providers = {
    docker = docker.vault
  }
}

module "container" {
  source = "./container"

  image          = module.image.image_id
  hostname       = var.hostname
  domain_name    = var.domain_name
  docker_ip      = var.docker_ip
  base_directory = var.base_directory
  vault_cluster  = var.vault_cluster
  container_name = var.container_name

  app_role_id         = var.app_role_id
  app_role_secret     = var.app_role_secret
  app_role_mount_path = var.app_role_mount_path

  docker_host     = var.docker_host
  docker_username = var.docker_username

  providers = {
    docker = docker.vault
  }

  depends_on = [
    module.image
  ]
}
