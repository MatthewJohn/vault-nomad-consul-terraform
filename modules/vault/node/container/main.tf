
module "server_certificate" {
  source = "./server_certificate"

  hostname     = var.docker_host.hostname
  vault_domain = local.vault_domain
  ip_address   = var.docker_host.ip

  vault_adm_pki_backend = var.vault_adm_pki_backend
  vault_adm_pki_role    = var.vault_adm_pki_role

  providers = {
    vault.vault-adm = vault.vault-adm
  }
}

resource "null_resource" "container_image" {
  triggers = {
    image = var.image
  }
}

resource "docker_container" "this" {
  image = var.image

  name    = "vault"
  rm      = false
  restart = "always"

  hostname   = "${var.docker_host.hostname}.${local.vault_domain}"
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

    # Disable proxy
    "http_proxy=",
    "https_proxy=",
    "HTTP_PROXY=",
    "HTTPS_PROXY=",
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
      log_opts,
      image,
    ]

    replace_triggered_by = [
      null_resource.vault_config,
      null_resource.container_image,
    ]
  }
}
