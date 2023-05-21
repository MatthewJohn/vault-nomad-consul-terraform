
resource "docker_container" "this" {
  image = var.image

  name    = "consul"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.datacenter.common_name}"
  domainname = ""

  command = concat(
    [
      "consul", "agent", "-config-file", "/consul/config/consul.hcl", "-config-format", "hcl"
    ]
  )

  user = "root"

  network_mode = "host"

  env = [
    # "VAULT_ROOT_CA_CERT=${var.vault_cluster.root_ca_cert}"
    # "VAULT_TOKEN="
  ]

  volumes {
    container_path = "/consul/data"
    host_path      = "/consul/data"
  }

  volumes {
    container_path = "/consul/config"
    host_path      = "/consul/config"
  }

  volumes {
    container_path = "/consul/vault"
    host_path      = "/consul/vault"
    read_only      = true
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.consul_config
    ]
  }
}
