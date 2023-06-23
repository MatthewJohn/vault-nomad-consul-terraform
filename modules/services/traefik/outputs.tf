output "service_name" {
  description = "Consul service name for traefik"
  value       = var.service_role.consul_service_name
}

output "service_domain" {
  description = "Domain name for services"
  value       = local.service_domain
}
