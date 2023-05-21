
module "consul_image" {
  source = "./image"

  consul_version = var.consul_version

  providers = {
    docker = docker.consul
  }
}

module "container" {
  source = "./container"

  image         = module.consul_image.image_id
  hostname      = var.hostname
  datacenter    = var.datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.root_cert
  gossip_key    = var.gossip_key
  initial_run   = var.initial_run

  docker_host     = var.docker_host
  docker_username = var.docker_username
  docker_ip       = var.docker_ip

  providers = {
    docker = docker.consul
   }
}
