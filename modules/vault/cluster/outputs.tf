output "ca_cert_file" {
  description = "Path to root CA file"
  value       = var.ca_cert_file
}

output "address" {
  description = "Address of cluster"
  value       = local.cluster_address
}

output "admin_token" {
  description = "Admin token"
  value       = module.admin_token.token
}

output "token" {
  description = "Terraform token"
  value       = module.terraform_token.token
}

output "consul_static_mount_path" {
  description = "Counsul static mount path"
  value       = vault_mount.consul_static.path
}
