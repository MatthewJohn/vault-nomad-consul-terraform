
locals {
  fqdn = "loki.${var.domain_name}"
}

resource "docker_container" "this" {
  image = "grafana/loki:2.2.1"

  name    = "loki"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.domain_name}"
  domainname = ""

  network_mode = "host"

  # Run as root to allow write access to data directories
  # @TODO Fix this
  user = "root"

  command = ["-config.file", "/loki/config/config.yml"]

  volumes {
    container_path = "/loki/data"
    host_path      = "/loki/data"
  }

  volumes {
    container_path = "/loki/config"
    host_path      = "/loki/config"
    read_only      = true
  }

  lifecycle {
    ignore_changes = [
      image
    ]

    replace_triggered_by = [
      null_resource.config
    ]
  }
}
