resource "freeipa_dns_record" "this" {
  zone_name = var.domain_name
  name      = var.vault_subdomain
  records   = var.ip_addresses
  type      = "A"
}