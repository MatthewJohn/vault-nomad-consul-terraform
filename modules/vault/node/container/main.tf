
module "server_certificate" {
  source = "./server_certificate"

  hostname     = var.hostname
  vault_domain = local.vault_domain
  ip_address   = var.docker_ip
}

resource "docker_container" "this" {
  image = var.image

  name    = "vault"
  rm      = false
  restart = "always"

  hostname   = "${var.hostname}.${local.vault_domain}"
  domainname = ""

  command = concat(
    [
      "vault", "server", "-config", "/vault/config.d/server.hcl"
    ]
  )

  # Use root for setting up permissions and let
  # entrypoint change user to "vault" user
  user = "root"

  capabilities {
    add = ["IPC_LOCK"]
  }

  network_mode = "host"

  env = [
    "SERVER_SSL_KEY=${module.server_certificate.private_key}",
    "SERVER_SSL_CERT=${module.server_certificate.full_chain}",
    "ROOT_CA_CERT=${module.server_certificate.root_ca_cert}",
  ]

  volumes {
    container_path = "/vault/config.d"
    host_path      = "/vault/config.d"
  }

  volumes {
    container_path = "/vault/logs"
    host_path      = "/vault/logs"
  }

  volumes {
    container_path = "/vault/file"
    host_path      = "/vault/file"
  }

  volumes {
    container_path = "/vault/raft"
    host_path      = "/vault/raft"
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
