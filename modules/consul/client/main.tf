
module "consul_image" {
  source = "./image"

  consul_version = var.consul_version

  providers = {
    docker = docker.consul
  }
}

module "consul_template_vault_agent" {
  source = "../../vault/agent"

  hostname       = var.hostname
  domain_name    = var.datacenter.common_name
  vault_cluster  = var.vault_cluster
  container_name = "consul-agent-vault-agent-consul-template"

  base_directory = "/consul-agent-vault-agent-consul-template"

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.datacenter.approle_mount_path

  docker_username = var.docker_username
  docker_host     = var.docker_host
  docker_ip       = var.docker_ip
}

module "container" {
  source = "./container"

  image         = module.consul_image.image_id
  hostname      = var.hostname
  datacenter    = var.datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.root_cert

  listen_host = var.listen_host
  listen_port = var.listen_port

  docker_host     = var.docker_host
  docker_username = var.docker_username
  docker_ip       = var.docker_ip

  consul_template_vault_agent = module.consul_template_vault_agent

  providers = {
    docker = docker.consul
  }
}
