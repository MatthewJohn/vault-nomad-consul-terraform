locals {
  consul_service_name = "traefik-http"
  service_domain      = "service.${var.nomad_datacenter.common_name}"
}