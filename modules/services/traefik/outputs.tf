output "service_name" {
  description = "Consul service name for traefik"
  value       = local.consul_service_name
}

output "service_domain" {
  description = "Domain name for services"
  value       = local.service_domain
}
