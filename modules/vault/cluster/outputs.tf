output "ca_cert_file" {
  description = "Path to root CA public key file"
  value       = var.ca_cert_file
}

output "ca_cert" {
  description = "Contents of root CA public key"
  value       = file(var.ca_cert_file)
}

output "ca_chain" {
  description = "CA Certificate chain"
  value       = local.full_chain
}

output "address" {
  description = "Address of cluster"
  value       = local.cluster_address
}

output "admin_token" {
  description = "Admin token"
  value       = module.admin_token.token
}

output "terraform_app_role" {
  description = "Terraform token"
  value       = {
    approle_mount_path = vault_auth_backend.approle.path
    role_id            = vault_approle_auth_backend_role.terraform.role_id
    secret_id          = vault_approle_auth_backend_role_secret_id.terraform.secret_id
  }
  sensitive = true
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

output "service_deployment_mount_path" {
  description = "Service deployment KV mount path"
  value       = vault_mount.deployment_secrets.path
}

output "terraform_aws_credential_secret_path" {
  description = "Secret path for Terraform AWS credentials"
  value       = vault_kv_secret_v2.terraform_aws_credentials.name
}

output "gitlab_jwt_auth_backend_path" {
  description = "Gitlab JWT auth backent"
  value       = vault_jwt_auth_backend.gitlab.path
}

output "approle_mount_path" {
  description = "Global approle mount path"
  value       = vault_auth_backend.approle.path
}