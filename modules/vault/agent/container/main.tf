
module "server_certificate" {
  source = "./server_certificate"

  hostname = var.hostname
  vault_domain = local.vault_domain
  ip_address = var.docker_ip
}

resource "docker_container" "this" {
  image = var.image

  name    = "vault-agent"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${local.vault_domain}"
  domainname = ""

  command = concat(
    [
      "vault", "agent", "-config", "/vault/config.d/agent.hcl"
    ]
  )

  # Use root for setting up permissions and let
  # entrypoint change user to "vault" user
  user = "root"

  capabilities {
    add = ["IPC_LOCK"]
  }

  volumes {
    container_path = "/vault-agent/config.d"
    host_path      = "/vault-agent/config.d"
    read_only      = true
  }

  volumes {
    container_path = "/vault-agent/auth"
    host_path      = "/vault-agent/auth"
  }

  volumes {
    container_path = "/vault-agent/ssl"
    host_path      = "/vault-agent/ssl"
    read_only      = true
  }

  lifecycle {
    ignore_changes = [
      image
    ]

    replace_triggered_by = [
      null_resource.vault_config
    ]
  }
}
