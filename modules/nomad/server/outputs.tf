output "hostname" {
  description = "Hostname of consul machine"
  value       = var.hostname
}

output "docker_username" {
  description = "SSH username to connect to docker host"
  value       = var.docker_username
}

output "docker_host" {
  description = "Docker host to connect to"
  value       = var.docker_host
}

output "docker_ip" {
  description = "IP Address of docker host"
  value       = var.docker_ip
}

output "nomad_https_port" {
  description = "Nomad HTTPS listen port"
  value       = var.nomad_https_port
}
