module "server_certificate" {
  source = "../server_certificate"

  hostname   = var.hostname
  datacenter = var.datacenter
  root_ca    = var.root_ca
  ip_address = var.docker_ip

  consul_binary = var.consul_binary
  initial_run   = var.initial_run

  aws_profile  = var.aws_profile
  aws_region   = var.aws_region
  aws_endpoint = var.aws_endpoint
}
