resource "freeipa_dns_record" "this" {
  zone_name = var.domain_name
  name      = "grafana"
  records   = [var.docker_ip]
  type      = "A"
}
