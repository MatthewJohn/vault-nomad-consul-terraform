resource "freeipa_dns_record" "this" {
  zone_name = var.service_role.nomad.root_domain_name
  name      = "*.${local.service_domain}"
  records   = [var.service_role.nomad.datacenter_client_dns]
  type      = "CNAME"
}
