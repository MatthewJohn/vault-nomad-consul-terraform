output "image_id" {
  description = "Image ID of the built image"
  value       = docker_image.this.image_id
}

output "remote_image" {
  description = "Remote image"
  value       = var.remote_image_name != null ? docker_registry_image.this[0].name : null
}