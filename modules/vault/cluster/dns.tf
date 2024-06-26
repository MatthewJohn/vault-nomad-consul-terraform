resource "freeipa_dns_record" "this" {
  zone_name = var.domain_name
  name      = var.vault_subdomain
  records   = var.ip_addresses
  type      = "A"
}

locals {
  # Local for cluster address, which is only available
  # once the DNS record has a valid ID, to avoid
  # DNS lookups before it's created.
  cluster_address = freeipa_dns_record.this.id != "" ? "https://${var.vault_subdomain}.${var.domain_name}:8200" : null
}