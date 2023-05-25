resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = "${var.datacenter}.${var.root_cert.subdomain}"
  records   = var.nomad_server_ips
  type      = "A"
}
