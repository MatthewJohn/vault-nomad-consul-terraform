
locals {
  fqdn = "grafana.${var.domain_name}"
}

resource "docker_container" "this" {
  image = "grafana/grafana-oss:9.5.3"

  name    = "grafana"
  rm      = false
  restart = "always"

  hostname   = "${var.hostname}.${var.domain_name}"
  domainname = ""

  network_mode = "host"

  # Use root user to allow access to data/config directories
  user = "root"

  env = [
    "GF_SERVER_ROOT_URL=http://${local.fqdn}:3000/",
    "GF_SECURITY_ADMIN_PASSWORD__FILE=/grafana/config/admin_password",
    "GF_INSTALL_PLUGINS=grafana-piechart-panel"
  ]

  volumes {
    container_path = "/var/lib/grafana"
    host_path      = "/grafana/data"
  }

  volumes {
    container_path = "/grafana/config"
    host_path      = "/grafana/config"
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
