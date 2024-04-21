
module "consul_image" {
  source = "./image"

  consul_version = var.consul_version
  vault_version  = var.vault_version
  http_proxy     = var.http_proxy

  providers = {
    docker = docker.consul
  }
}

# module "consul_template_vault_agent" {
#   source = "../../vault/agent"

#   domain_name    = var.datacenter.common_name
#   container_name = "consul-agent-vault-agent-consul-template"

#   base_directory = "/consul-agent-vault-agent-consul-template"

#   app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
#   app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
#   app_role_mount_path = var.datacenter.approle_mount_path

#   docker_host = var.docker_host

#   vault_cluster = var.vault_cluster
#   http_proxy    = var.http_proxy
#   vault_version = var.vault_version
# }

module "container" {
  source = "./container"

  image         = module.consul_image.image_id
  datacenter    = var.datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.root_cert

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.datacenter.approle_mount_path

  listen_host = var.listen_host
  listen_port = var.listen_port

  docker_host = var.docker_host

  providers = {
    docker = docker.consul
  }
}
