resource "freeipa_dns_record" "this" {
  zone_name = var.domain_name
  name      = "victoriametrics"
  records   = [docker_container.this.network_data[0].ip_address]
  type      = "A"
}
