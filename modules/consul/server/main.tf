
module "consul_image" {
  source = "./image"

  consul_version = var.consul_version

  providers = {
    docker = docker.consul
  }
}

module "consul_template_vault_agent" {
  source = "../../vault/agent"

  vault_cluster  = var.vault_cluster
  domain_name    = var.datacenter.common_name
  container_name = "vault-agent-consul-template"

  base_directory = "/vault-agent-consul-template"

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.datacenter.approle_mount_path

  docker_host     = var.docker_host
}

module "container" {
  source = "./container"

  image         = module.consul_image.image_id
  datacenter    = var.datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.root_cert
  initial_run   = var.initial_run

  connect_ca_approle_role_id   = data.vault_approle_auth_backend_role_id.connect_ca.role_id
  connect_ca_approle_secret_id = vault_approle_auth_backend_role_secret_id.connect_ca.secret_id

  docker_host = var.docker_host

  consul_template_vault_agent = module.consul_template_vault_agent

  providers = {
    docker = docker.consul
  }
}
