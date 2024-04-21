
resource "docker_container" "this" {
  image = "quay.io/prometheus/node-exporter:v1.6.0"

  name    = "node_exporter"
  rm      = false
  restart = "always"

  hostname   = var.docker_host.fqdn
  domainname = ""

  network_mode = "host"
  pid_mode     = "host"

  command = ["--path.rootfs=/host"]

  mounts {
    target = "/host"
    type   = "bind"
    source = "/"
    bind_options {
      propagation = "rslave"
    }
  }

  lifecycle {
    ignore_changes = [
      image,
      log_opts
    ]
  }
}
