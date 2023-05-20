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

output "admin_token" {
  description = "Admin token"
  value       = module.admin_token.token
}

output "token" {
  description = "Terraform token"
  value       = module.terraform_token.token
}
