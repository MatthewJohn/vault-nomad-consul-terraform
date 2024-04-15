
output "name" {
  description = "Datacenter name"
  value       = var.datacenter
}

output "common_name" {
  description = "Common name"
  value       = local.common_name
}

output "app_domain" {
  description = "App domain for DC"
  value       = "${var.datacenter}.${var.app_cert.common_name}"
}

output "app_service_domain" {
  description = "App service domain for DC"
  value       = "service.${var.datacenter}.${var.app_cert.common_name}"
}

output "role_name" {
  description = "Role name for certificate"
  value       = vault_pki_secret_backend_role.this.name
}

output "client_ca_role_name" {
  description = "Role name for client certificates"
  value       = vault_pki_secret_backend_role.client.name
}

output "pki_mount_path" {
  description = "PKI path"
  value       = var.root_cert.pki_mount_path # vault_mount.this.path
}

output "root_cert_public_key" {
  description = "Root cert public key"
  value       = var.root_cert.public_key
}

output "ca_chain" {
  description = "Intermediate certificate CA chain"
  value       = var.root_cert.public_key # join("\n", vault_pki_secret_backend_root_sign_intermediate.this.ca_chain)
}

output "address" {
  description = "Endpoint for cluster"
  value       = "https://${local.common_name}:8501"
}

output "address_wo_protocol" {
  description = "Endpoint for cluster without protocol"
  value       = "${local.common_name}:8501"
}

output "static_mount_path" {
  description = "Vault mount path for consul static tokens"
  value       = var.vault_cluster.consul_static_mount_path
}

output "primary_datacenter" {
  description = "Whether the datacenter is the primary datacenter"
  value       = local.is_primary_datacenter
}

output "consul_engine_mount_path" {
  description = "Mount path for vault consul secret engine"
  value       = local.consul_engine_mount_path
}

output "approle_mount_path" {
  description = "Path for vault approle mount path for datacenter"
  value       = vault_auth_backend.approle.path
}

output "agent_consul_template_policy" {
  description = "Role for agent consul-template to authenticate to vault"
  value       = vault_policy.agent_consul_template.name
}

output "server_consul_template_approle_role_name" {
  description = "Role name for consul server consul template approle"
  value       = vault_approle_auth_backend_role.server_consul_template.role_name
}

output "client_consul_template_policy" {
  description = "Role for consul client consul-template to authenticate to vault"
  value       = vault_policy.consul_client_consul_template.name
}

output "client_consul_template_approle_role_name" {
  description = "Role name for consul client consul-template approle"
  value       = vault_approle_auth_backend_role.consul_client_consul_template.role_name
}

# Consul connect
output "pki_connect_mount_path" {
  description = "PKI path for consul connect"
  value       = vault_mount.connect_intermediate.path
}

output "connect_ca_policy" {
  description = "Consul connect CA policy name"
  value       = vault_policy.connect_ca.name
}

output "connect_ca_approle_role_name" {
  description = "Role name for consul server consul template approle"
  value       = vault_approle_auth_backend_role.connect_ca.role_name
}

output "consul_server_token" {
  description = "S3 details for consul server token"
  value = {
    mount = vault_kv_secret_v2.static_token.mount
    name  = vault_kv_secret_v2.static_token.name
  }
}

output "gossip_encryption" {
  description = "Vault details for consul gossip token"
  value = {
    mount = vault_kv_secret_v2.gossip.mount
    name  = vault_kv_secret_v2.gossip.name
  }
}
