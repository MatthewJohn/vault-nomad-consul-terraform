resource "freeipa_dns_record" "this" {
  zone_name = var.domain_name
  name      = var.name
  records   = [var.ip_address]
  type      = "A"
}