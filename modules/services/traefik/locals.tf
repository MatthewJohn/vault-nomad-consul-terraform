locals {
  service_domain      = "web.${var.service_role.nomad.datacenter_common_name}"
}