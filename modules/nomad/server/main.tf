
module "image" {
  source = "./image"

  nomad_version = var.nomad_version

  providers = {
    docker = docker.consul
  }
}

module "consul_template_vault_agent" {
  source = "../../vault/agent"

  hostname       = var.hostname
  domain_name    = var.region.common_name
  vault_cluster  = var.vault_cluster
  container_name = "vault-agent-consul-template"

  base_directory = "/vault-agent-consul-template"

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.region.approle_mount_path

  docker_username = var.docker_username
  docker_host     = var.docker_host
  docker_ip       = var.docker_ip
}

module "container" {
  source = "./container"

  image         = module.image.image_id
  hostname      = var.hostname
  region        = var.region
  vault_cluster = var.vault_cluster

  docker_host     = var.docker_host
  docker_username = var.docker_username
  docker_ip       = var.docker_ip

  consul_template_vault_agent = module.consul_template_vault_agent

  providers = {
    docker = docker.consul
  }
}
