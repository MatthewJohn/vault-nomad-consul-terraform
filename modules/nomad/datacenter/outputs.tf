output "name" {
  description = "Name of datacenter"
  value       = var.datacenter
}

output "common_name" {
  description = "Common name"
  value       = local.common_name
}

output "client_pki_role_name" {
  description = "Role name for client certificate"
  value       = vault_pki_secret_backend_role.client.name
}

output "pki_mount_path" {
  description = "PKI path"
  value       = var.region.pki_mount_path
}

output "root_cert_public_key" {
  description = "Root cert public key"
  value       = var.root_cert.public_key
}

output "client_dns" {
  description = "DNS for region servers"
  value       = "client.${local.common_name}"
}

output "client_consul_template_approle_role_name" {
  description = "Role name for nomad client consul template approle"
  value       = vault_approle_auth_backend_role.client_consul_template.role_name
}

output "vault_jwt_path" {
  description = "Workload identity JWT engine path"
  value       = vault_jwt_auth_backend.workload_identity.path
}

output "default_workload_vault_policy" {
  description = "Default workload vault policy"
  value       = vault_policy.default_workload_identity.name
}

output "default_workload_vault_role" {
  description = "Default role for workload identity for vault"
  value       = vault_jwt_auth_backend_role.default_workload_identity.role_name
}

output "workload_identity_vault_aud" {
  description = "Vault workload identity AUD"
  value       = vault_jwt_auth_backend_role.default_workload_identity.bound_audiences
}

output "consul_auth_method" {
  description = "Workload identity JWT auth method for consul"
  value       = consul_acl_auth_method.jwt.name
}

output "default_workload_consul_policy" {
  description = "Default workload consul policy"
  value       = consul_acl_policy.workload_identity_task.name
}

output "default_workload_consul_task_role" {
  description = "Default task role for workload identity for consul"
  value       = consul_acl_role.task.name
}

output "workload_identity_consul_aud" {
  description = "Consul workload identity AUD"
  value       = jsondecode(consul_acl_auth_method.jwt.config_json)["BoundAudiences"]
}

output "harbor_account" {
  description = "Harbor account"
  value       = {
    secret_mount = vault_kv_secret_v2.harbor.mount
    secret_name  = vault_kv_secret_v2.harbor.name
  }
}