output "container_id" {
  description = "Container ID - used for forcing resources to wait for built container"
  value       = module.container.container_id
}

output "token_directory" {
  description = "Directory containing token"
  value       = module.container.token_directory
}

output "token_path" {
  description = "Host path of generated token"
  value       = module.container.token_path
}
