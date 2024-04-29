module "container" {
  source = "./container"

  image          = var.docker_images.vault_agent_image
  base_directory = var.base_directory
  vault_cluster  = var.vault_cluster
  container_name = var.container_name

  app_role_id         = var.app_role_id
  app_role_secret     = var.app_role_secret
  app_role_mount_path = var.app_role_mount_path

  docker_host = var.docker_host
  domain_name = var.domain_name

  providers = {
    docker = docker.vault
  }
}
