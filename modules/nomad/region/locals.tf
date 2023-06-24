locals {
  common_name         = "${var.region}.${var.root_cert.common_name}"
  nomad_verify_domain = "${var.region}.nomad"
  server_common_name  = "server.${local.common_name}"
  server_address      = "https://${local.server_common_name}:4646"
}
