resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = "*.${local.service_domain}"
  records   = [var.nomad_datacenter.client_dns]
  type      = "CNAME"
}
