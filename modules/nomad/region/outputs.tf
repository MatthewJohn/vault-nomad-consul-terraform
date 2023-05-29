
output "name" {
  description = "Region name"
  value       = var.region
}

output "common_name" {
  description = "Common name"
  value       = local.common_name
}

output "role_name" {
  description = "Role name for certificate"
  value       = vault_pki_secret_backend_role.this.name
}

output "client_pki_role_name" {
  description = "Role name for client certificate"
  value       = vault_pki_secret_backend_role.client.name
}

output "pki_mount_path" {
  description = "PKI path"
  value       = vault_mount.this.path
}

output "root_cert_public_key" {
  description = "Root cert public key"
  value       = var.root_cert.public_key
}

output "server_dns" {
  description = "DNS for region servers"
  value       = "server.${local.common_name}"
}

output "address" {
  description = "Endpoint for cluster"
  value       = "http://server.${local.common_name}:4646"
}

output "address_wo_protocol" {
  description = "Endpoint for cluster without protocol"
  value       = "server.${local.common_name}:4646"
}

output "approle_mount_path" {
  description = "Path for vault approle mount path for region"
  value       = vault_auth_backend.approle.path
}

output "server_consul_template_approle_role_name" {
  description = "Role name for nomad server consul template approle"
  value       = vault_approle_auth_backend_role.server_consul_template.role_name
}

output "server_consul_template_policy" {
  description = "Role for server consul-template to authenticate to vault"
  value       = vault_policy.server_consul_template.name
}

output "client_consul_template_approle_role_name" {
  description = "Role name for nomad client consul template approle"
  value       = vault_approle_auth_backend_role.client_consul_template.role_name
}
