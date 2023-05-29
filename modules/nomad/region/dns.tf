resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = "server.${var.region}.${var.root_cert.subdomain}"
  records   = var.nomad_server_ips
  type      = "A"
}
