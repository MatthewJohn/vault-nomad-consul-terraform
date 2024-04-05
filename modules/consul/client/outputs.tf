output "port" {
  description = "Port container is listening on"
  value       = var.listen_port
}

output "listen_host" {
  description = "Host the client is listening on"
  value       = var.listen_host
}

output "agent_name" {
  description = "Agent name"
  value       = "consul-client-${var.datacenter.name}-${var.docker_host.hostname}"
}
