
module "consul_image" {
  source = "./image"

  consul_version = var.consul_version

  providers = {
    docker = docker.consul
  }
}