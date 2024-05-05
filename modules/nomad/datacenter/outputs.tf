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

output "consul_auth_method" {
  description = "Workload identity JWT auth method for consul"
  value       = consul_acl_auth_method.jwt.name
}

output "harbor_account" {
  description = "Harbor account"
  value       = {
    secret_mount = vault_kv_secret_v2.harbor.mount
    secret_name  = vault_kv_secret_v2.harbor.name
  }
}