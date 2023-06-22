output "consul_service_name" {
  description = "Primary consul service name"
  value       = local.consul_service_name
}

output "consul_policy_name" {
  description = "Name of consul policy"
  value       = consul_acl_policy.this.name
}

output "vault_consul_role_name" {
  description = "Vault consul engine role name for consul token"
  value       = vault_consul_secret_backend_role.this.name
}

output "vault_consul_engine_path" {
  description = "Vault consul engine path"
  value       = var.consul_datacenter.consul_engine_mount_path
}

output "vault_approle_deployment_role_id" {
  description = "Vault approle role ID for deployment"
  value       = vault_approle_auth_backend_role.deployment.role_id
}
output "vault_approle_deployment_secret_id" {
  description = "Vault approle secret ID for deployment"
  value       = vault_approle_auth_backend_role_secret_id.deployment.secret_id
}

output "vault_approle_deployment_path" {
  description = "Vault approle path for deployment"
  value       = var.nomad_region.approle_mount_path
}

output "vault_secret_base_path" {
  description = "Base path for vault secrets"
  value       = local.vault_secret_base_path
}

output "vault_secret_base_data_path" {
  description = "Base data path for vault secrets"
  value       = local.vault_secret_base_data_path
}

output "vault_deploy_policy" {
  description = "Vault policy name for deployment"
  value       = vault_policy.deployment_policy.name
}

output "vault_application_policy" {
  description = "Vault policy name for application"
  value       = vault_policy.application_policy.name
}

output "vault" {
  description = "Deployment details for vault cluster"
  value = {
    ca_cert = var.vault_cluster.ca_cert
    address = var.vault_cluster.address
  }
}

output "consul" {
  description = "Connection details for Consul"
  value = {
    datacenter_name      = var.consul_datacenter.name
    address              = var.consul_datacenter.address
    address_wo_protocol  = var.consul_datacenter.address_wo_protocol
    root_cert_public_key = var.consul_datacenter.root_cert_public_key
  }
}

output "nomad" {
  description = "Deployment details for nomad cluster"
  value = {
    address              = var.nomad_region.address
    root_cert_public_key = var.nomad_region.root_cert_public_key
    region               = var.nomad_region.name
    datacenter           = var.nomad_datacenter.name
  }
}

