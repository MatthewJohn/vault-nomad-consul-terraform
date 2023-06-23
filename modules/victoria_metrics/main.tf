
locals {
  fqdn = "victoriametrics.${var.domain_name}"
}

resource "docker_container" "this" {
  image = "victoriametrics/victoria-metrics:v1.91.2"

  name    = "victoria-metrics"
  rm      = false
  restart = "always"

  hostname   = "${var.hostname}.${var.domain_name}"
  domainname = ""

  network_mode = "host"

  command = ["-promscrape.config", "/victoria-metrics-config/scrape.yml"]

  volumes {
    container_path = "/victoria-metrics-data"
    host_path      = "/victoria-metrics/data"
  }

  volumes {
    container_path = "/victoria-metrics-config"
    host_path      = "/victoria-metrics/config"
  }

  volumes {
    container_path = module.vault_agent.token_directory
    host_path      = module.vault_agent.token_directory
    read_only      = true
  }

  # Mount consul client cert directory for CA
  volumes {
    container_path = "/consul/config/client-certs"
    host_path      = "/consul/config/client-certs"
  }

  lifecycle {
    ignore_changes = [
      image
    ]

    replace_triggered_by = [
      null_resource.config
    ]
  }
}

module "consul_client" {
  source = "../consul/client"

  hostname      = var.hostname
  domain_name   = var.domain_name
  datacenter    = var.consul_datacenter
  vault_cluster = var.vault_cluster
  root_cert     = var.consul_root_cert
  gossip_key    = var.consul_gossip_key

  consul_version = var.consul_version

  docker_username = var.docker_username
  docker_host     = var.docker_host
  docker_ip       = var.docker_ip
}
