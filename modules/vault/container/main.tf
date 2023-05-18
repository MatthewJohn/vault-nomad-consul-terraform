
resource "docker_container" "this" {
  image = var.image

  name    = "vault"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.domain_name}"
  domainname = ""

  command = concat(
    [
      "vault", "server", "-config", "/vault/config.d/server.hcl"
    ]
  )

  # Use root for setting up permissions and let
  # entrypoint change user to "vault" user
  user = "root"

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
    "VAULT_API_ADDR=https://0.0.0.0:8200",
    "VAULT_CLUSTER_ADDR=http://0.0.0.0:8201"
  ]

  ports {
    internal = 8200
    external = 8200
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

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

  lifecycle {
    ignore_changes = [image]
  }
}