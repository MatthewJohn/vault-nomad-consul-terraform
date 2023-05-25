
resource "docker_container" "this" {
  image = var.image

  name    = "nomad"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.datacenter.common_name}"
  domainname = ""

  command = concat(
    [
      "nomad", "agent", "-config", "/nomad/config/server.hcl"
    ]
  )

  user = "root"

  # Use privileged mode to allow listening on any port
  privileged = true

  network_mode = "host"

  env = [
    # "VAULT_ROOT_CA_CERT=${var.vault_cluster.root_ca_cert}"
    # "VAULT_TOKEN="
  ]

  volumes {
    container_path = "/nomad/data"
    host_path      = "/nomad/data"
  }

  volumes {
    container_path = "/nomad/config"
    host_path      = "/nomad/config"
  }

  volumes {
    container_path = "/nomad/vault"
    host_path      = "/nomad/vault"
    read_only      = true
  }

  volumes {
    container_path = "/vault-agent-consul-template/auth"
    host_path      = var.consul_template_vault_agent.token_directory
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.noamd_config
    ]
  }
}
