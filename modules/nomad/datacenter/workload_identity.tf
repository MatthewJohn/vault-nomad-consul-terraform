resource "vault_policy" "default_workload_identity" {
  name = "default-identity-${var.region.name}-${var.datacenter}"

  policy = <<EOF
path "${var.vault_cluster.service_secrets_mount_path}/data/${var.region.name}/${var.datacenter}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_job_id}}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_task}}/*" {
  capabilities = ["read"]
}

path "${var.vault_cluster.service_secrets_mount_path}/data/${var.region.name}/${var.datacenter}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_job_id}}/common/*" {
  capabilities = ["read"]
}

path "${var.vault_cluster.service_secrets_mount_path}/data/${var.region.name}/${var.datacenter}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_job_id}}/*" {
  capabilities = ["read"]
}

path "${var.vault_cluster.service_secrets_mount_path}/metadata/${var.region.name}/${var.datacenter}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_job_id}}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_task}}/*" {
  capabilities = ["read"]
}

path "${var.vault_cluster.service_secrets_mount_path}/metadata/${var.region.name}/${var.datacenter}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_job_id}}/common/*" {
  capabilities = ["read"]
}

path "${var.vault_cluster.service_secrets_mount_path}/metadata/${var.region.name}/${var.datacenter}/{{identity.entity.aliases.${vault_jwt_auth_backend.workload_identity.accessor}.metadata.nomad_job_id}}" {
  capabilities = ["read"]
}

path "${var.vault_cluster.service_secrets_mount_path}/metadata/${var.region.name}/${var.datacenter}/*" {
  capabilities = ["list"]
}

path "${var.vault_cluster.service_secrets_mount_path}/metadata/${var.region.name}/*" {
  capabilities = ["list"]
}

path "${var.vault_cluster.service_secrets_mount_path}/metadata/*" {
  capabilities = ["list"]
}
EOF
}

resource "vault_jwt_auth_backend_role" "default_workload_identity" {
  backend   = vault_jwt_auth_backend.workload_identity.path
  role_name = "default-identity-${var.region.name}-${var.datacenter}"
  token_policies = [
    "default-identity-${var.region.name}-${var.datacenter}"
  ]

  # bound_claims = {
  # }
  claim_mappings = {
    nomad_namespace = "nomad_namespace"
    nomad_job_id    = "nomad_job_id"
    nomad_task      = "nomad_task"
  }
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true
  role_type               = "jwt"
  token_type              = "service"
  bound_audiences         = ["vault.io"]
  token_period            = 30 * 60 # 30 minutes
}