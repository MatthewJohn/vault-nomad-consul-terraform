output "container_id" {
  description = "Container ID - used for forcing resources to wait for built container"
  value       = docker_container.this.id
}

output "token_directory" {
  description = "Directory containing token"
  value       = "${var.base_directory}/auth"
}

output "token_path" {
  description = "Host path of generated token"
  value       = "${var.base_directory}/auth/token"
}
