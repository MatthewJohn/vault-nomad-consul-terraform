output "docker_host" {
  description = "Hostname of consul machine"
  value       = var.docker_host
}

output "nomad_https_port" {
  description = "Nomad HTTPS listen port"
  value       = var.nomad_https_port
}
