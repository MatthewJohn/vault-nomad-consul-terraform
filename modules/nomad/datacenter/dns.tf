resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = "client.${var.datacenter}.${var.region.common_name}"
  records   = var.nomad_client_ips
  type      = "A"
}
