output "ca_cert_file" {
  description = "Path to root CA file"
  value       = var.ca_cert_file
}

output "address" {
  description = "Address of cluster"
  value       = local.cluster_address
}

output "admin_policy" {
  description = "Name of admin policy"
  value       = module.admin_token.admin_policy
}

output "admin_role" {
  description = "Name of admin role"
  value       = module.admin_token.admin_role
}

output "admin_token" {
  description = "Admin token"
  value       = module.admin_token.admin_token
}
