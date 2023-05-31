resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = "*.service.${var.nomad_datacenter.common_name}"
  records   = [var.nomad_datacenter.client_dns]
  type      = "CNAME"
}
