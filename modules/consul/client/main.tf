module "consul_template_vault_agent" {
  source = "../../vault/agent"

  domain_name    = var.datacenter.common_name
  container_name = "consul-agent-vault-agent-consul-template"

  base_directory = "/consul-agent-vault-agent-consul-template"

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.datacenter.approle_mount_path

  docker_host = var.docker_host

  vault_cluster = var.vault_cluster

  docker_images = var.docker_images
}

module "container" {
  source = "./container"

  image         = var.docker_images.consul_client_image
  datacenter    = var.datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.root_cert

  vault_consul_role = var.custom_role != null ? var.custom_role.vault_consul_role : "consul-client-role"

  use_token_as_default = var.use_token_as_default

  listen_host = var.listen_host
  listen_port = var.listen_port

  docker_host = var.docker_host

  consul_template_vault_agent = module.consul_template_vault_agent

  providers = {
    docker = docker.consul
  }
}
