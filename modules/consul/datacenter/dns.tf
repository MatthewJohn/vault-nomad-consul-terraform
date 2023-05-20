resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = var.root_cert.consul_subdomain
  records   = var.agent_ips
  type      = "A"
}
