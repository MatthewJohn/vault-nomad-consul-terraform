output "mount" {
  description = "Secret mount"
  value       = var.mount
}
output "path" {
  description = "Secret path"
  value       = var.path
}
output "mount_path" {
  description = "Mount with path"
  value       = "${var.mount}/${var.path}"
}
output "metadata" {
  description = "Mount with path"
  value       = "${var.mount}/metadata/${var.path}"
}
output "data" {
  description = "Mount with path"
  value       = "${var.mount}/data/${var.path}"
}