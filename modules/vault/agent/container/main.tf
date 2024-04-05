
resource "docker_container" "this" {
  image = var.image

  name    = var.container_name
  rm      = false
  restart = "always"

  hostname   = "${var.docker_host.hostname}.${var.domain_name}"
  domainname = ""

  command = concat(
    [
      "vault", "agent", "-config", "/vault-agent/config.d/agent.hcl"
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
    host_path      = "${var.base_directory}/config.d"
    read_only      = true
  }

  # Fix shared access from host and container, since it's
  # shared with multiple containers
  mounts {
    target = "/vault-agent/auth"
    type   = "bind"
    source = "${var.base_directory}/auth"
    bind_options {
      propagation = "shared"
    }
  }

  volumes {
    container_path = "/vault-agent/ssl"
    host_path      = "${var.base_directory}/ssl"
    read_only      = true
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.config_files
    ]
  }
}
