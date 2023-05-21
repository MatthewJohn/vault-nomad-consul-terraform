
output "name" {
  description = "Datacenter name"
  value       = var.datacenter
}

output "common_name" {
  description = "Common name"
  value       = local.common_name
}

output "role_name" {
  description = "Role name for certificate"
  value       = vault_pki_secret_backend_role.this.name
}

output "pki_mount_path" {
  description = "PKI path"
  value       = vault_mount.this.path
}

output "agent_consul_template_policy" {
  description = "Role for agent consul-template to authenticate to vault"
  value       = vault_policy.agent_ca.name
}

output "root_cert_public_key" {
  description = "Root cert public key"
  value       = var.root_cert.public_key
}

output "address" {
  description = "Endpoint for cluster"
  value       = "http://${local.common_name}:8500"
}

output "static_mount_path" {
  description = "Vault mount path for consul static tokens"
  value = var.vault_cluster.consul_static_mount_path
}

output "primary_datacenter" {
  description = "Whether the datacenter is the primary datacenter"
  value       = local.is_primary_datacenter
}
