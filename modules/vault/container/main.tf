
resource "docker_container" "this" {
  image = "vault:${var.vault_version}"

  name    = "vault"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.domain_name}"
  domainname = ""

  #   command = concat(
  #     [
  #       "-U", "--auto-forwarders",
  #       "-r", "DOCK.LOCAL", "--setup-dns", "--ds-password", "dirpassword",
  #       "--no-dnssec-validation", "--no-host-dns",
  #       "--admin-password", var.freeipa_password
  #     ]
  #   )

  #   env = concat(
  #     [
  #       "DEBUG_TRACE=1",
  #       "DEBUG_NO_EXIT=1"
  #     ]
  #   )

  capabilities {
    add = ["IPC_LOCK"]
  }

  env = [
    "VAULT_LOCAL_CONFIG=${local.vault_config_stripped}",
  ]

  ports {
    internal = 8200
    external = 8200
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  volumes {
    container_path = "/vault/logs"
    host_path      = "/vault/logs"
  }

  volumes {
    container_path = "/vault/file"
    host_path      = "/vault/file"
  }

  lifecycle {
    ignore_changes = [image]
  }
}
