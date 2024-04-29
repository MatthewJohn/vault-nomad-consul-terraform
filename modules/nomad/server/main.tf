module "consul_client" {
  source = "../../consul/client"

  # domain_name   = var.region.common_name
  datacenter    = var.consul_datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.consul_root_cert

  custom_role = {
    # Use fake ternary to force waiting for role ID to exist before passing in the state name
    # as this is used in a data lookup, which will fail is immediately able to run during plan
    approle_name      = vault_approle_auth_backend_role.consul_client_consul_template.id != "" ? vault_approle_auth_backend_role.consul_client_consul_template.role_name : ""
    vault_consul_role = vault_consul_secret_backend_role.nomad_server_vault_consul_role.name
  }

  use_token_as_default = true

  docker_images = var.docker_images

  docker_host = var.docker_host
}

module "consul_template_vault_agent" {
  source = "../../vault/agent"

  domain_name    = var.region.common_name
  vault_cluster  = var.vault_cluster
  container_name = "vault-agent-consul-template"

  base_directory = "/vault-agent-consul-template"

  docker_images = var.docker_images

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.region.approle_mount_path

  docker_host = var.docker_host
}

module "container" {
  source = "./container"

  image                          = var.docker_images.nomad_image
  root_cert                      = var.root_cert
  region                         = var.region
  vault_cluster                  = var.vault_cluster
  consul_client                  = module.consul_client
  consul_datacenter              = var.consul_datacenter
  initial_run                    = var.initial_run
  nomad_server_vault_consul_role = vault_consul_secret_backend_role.nomad_server_vault_consul_role.name
  nomad_https_port               = var.nomad_https_port

  docker_host = var.docker_host

  consul_template_vault_agent = module.consul_template_vault_agent

  providers = {
    docker = docker.consul
  }
}
