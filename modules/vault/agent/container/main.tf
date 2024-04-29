resource "null_resource" "container_image" {
  triggers = {
    image = var.image
  }
}

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

  # @TODO Convert to bind.
  # If you modify the file on the host and then restart the container
  # the file is not repopulated.
  # This requires the "auth" directory to exists on machines beforehand
  volumes {
    container_path = "/vault-agent/auth"
    host_path      = "${var.base_directory}/auth"
  }

  volumes {
    container_path = "/vault-agent/ssl"
    host_path      = "${var.base_directory}/ssl"
    read_only      = true
  }

  lifecycle {
    ignore_changes = [
      log_opts,
      image,
    ]

    replace_triggered_by = [
      null_resource.config_files,
      null_resource.container_image,
    ]
  }
}
