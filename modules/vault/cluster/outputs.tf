output "ca_cert_file" {
  description = "Path to root CA public key file"
  value       = var.ca_cert_file
}

output "ca_cert" {
  description = "Contents of root CA public key"
  value       = file(var.ca_cert_file)
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

output "pki_mount_path" {
  description = "PKI mount path"
  value       = vault_mount.pki.path
}

output "consul_static_mount_path" {
  description = "Counsul static mount path"
  value       = vault_mount.consul_static.path
}

output "service_secrets_mount_path" {
  description = "Service secrets KV mount path"
  value       = vault_mount.service_secrets.path
}

output "approle_mount_path" {
  description = "Global approle mount path"
  value       = vault_auth_backend.approle.path
}