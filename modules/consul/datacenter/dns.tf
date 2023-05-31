resource "freeipa_dns_record" "this" {
  zone_name = var.root_cert.domain_name
  name      = "${var.datacenter}.${var.root_cert.subdomain}"
  records   = var.agent_ips
  type      = "A"
}

resource "freeipa_dns_record" "server" {
  zone_name = var.root_cert.domain_name
  name      = "server.${var.datacenter}.${var.root_cert.subdomain}"
  records   = var.agent_ips
  type      = "A"
}
