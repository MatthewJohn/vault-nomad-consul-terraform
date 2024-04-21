
resource "docker_container" "this" {
  image = var.image

  name    = "consul-client"
  rm      = false
  restart = "always"

  hostname   = "${var.docker_host.hostname}.${var.datacenter.common_name}"
  domainname = ""

  command = concat(
    [
      "consul", "agent", "-config-file", "/consul/config/consul.hcl", "-config-format", "hcl"
    ]
  )

  user = "root"

  # Use privileged mode to allow listening on port 53
  privileged = true

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

  volumes {
    container_path = "/consul-client-vault-agent-consul-template/auth"
    host_path      = var.consul_template_vault_agent.token_directory
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.consul_config
    ]
    ignore_changes = [
      log_opts
    ]
  }
}
