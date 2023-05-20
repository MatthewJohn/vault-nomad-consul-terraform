output "image_id" {
  description = "Image ID of the built image"
  value       = docker_image.this.image_id
}