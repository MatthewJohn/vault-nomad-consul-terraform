locals {
  consul_service_name = "traefik-http"
  service_domain      = "web.${var.nomad_datacenter.common_name}"
}