
module "image" {
  source = "../image"

  nomad_version  = var.nomad_version
  consul_version = var.consul_version


  providers = {
    docker = docker.consul
  }
}

module "consul_client" {
  source = "../../consul/client"

  hostname      = var.hostname
  domain_name   = var.datacenter.common_name
  datacenter    = var.consul_datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.consul_root_cert
  http_proxy    = var.http_proxy

  consul_version = var.consul_version

  docker_username = var.docker_username
  docker_host     = var.docker_host
  docker_ip       = var.docker_ip
}

module "consul_template_vault_agent" {
  source = "../../vault/agent"

  domain_name    = var.region.common_name
  vault_cluster  = var.vault_cluster
  container_name = "vault-agent-consul-template"
  vault_version  = var.vault_version
  http_proxy     = var.http_proxy

  base_directory = "/vault-agent-consul-template"

  app_role_id         = data.vault_approle_auth_backend_role_id.consul_template.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.consul_template.secret_id
  app_role_mount_path = var.region.approle_mount_path

  docker_host     = var.docker_host
}

module "container" {
  source = "./container"

  image                          = module.image.image_id
  hostname                       = var.hostname
  root_cert                      = var.root_cert
  region                         = var.region
  datacenter                     = var.datacenter
  vault_cluster                  = var.vault_cluster
  consul_root_cert               = var.consul_root_cert
  consul_client                  = module.consul_client
  consul_datacenter              = var.consul_datacenter
  nomad_client_vault_consul_role = vault_consul_secret_backend_role.nomad_client_vault_consul_role.name

  docker_host     = var.docker_host
  docker_username = var.docker_username
  docker_ip       = var.docker_ip

  consul_template_vault_agent = module.consul_template_vault_agent

  providers = {
    docker = docker.consul
  }
}
