
resource "docker_container" "this" {
  image = "victoriametrics/victoria-metrics:v1.91.2"

  name    = "victoria-metrics"
  rm      = false
  restart = "on-failure"

  hostname   = "${var.hostname}.${var.datacenter.common_name}"
  domainname = ""

  volumes {
    container_path = "/victoria-metrics-data"
    host_path      = "/local-ds-setup/victoriametrics"
  }
}
