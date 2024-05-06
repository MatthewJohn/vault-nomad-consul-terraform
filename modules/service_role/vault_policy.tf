
locals {
  vault_terraform_policy_role = local.enable_nomad_integration ? "nomad-terraform-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.job_name}" : "terraform-${var.job_name}"
  vault_secret_path           = local.enable_nomad_integration ? "${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.job_name}" : "pipelines/${var.gitlab_project_path}"
  deployment_secret_path      = local.enable_nomad_integration ? "konvad/services/${local.vault_secret_path}" : local.vault_secret_path
}

module "deployment_secret_path" {
  source = "../helpers/vault_paths"

  mount = var.vault_cluster.service_deployment_mount_path
  path  = local.deployment_secret_path
}
module "base_secret_path" {
  source = "../helpers/vault_paths"

  mount = var.vault_cluster.service_secrets_mount_path
  path  = local.vault_secret_path
}
module "common_service_secret_path" {
  source = "../helpers/vault_paths"

  mount = var.vault_cluster.service_secrets_mount_path
  path  = "${local.vault_secret_path}/common"
}
module "task_service_secret_path" {
  for_each = var.tasks

  source = "../helpers/vault_paths"

  mount = var.vault_cluster.service_secrets_mount_path
  path  = "${local.vault_secret_path}/${each.key}"
}

# Custom policy that will be attached to the application
resource "vault_policy" "custom_application_policy" {
  for_each = {
    for task, task_config in var.tasks :
    task => task_config
    if task_config.custom_vault_policy != null
  }

  name = "${local.base_full_name}-${each.key}"

  policy = each.value.custom_vault_policy
}

resource "vault_jwt_auth_backend_role" "default_workload_identity" {
  for_each = {
    for task, task_config in var.tasks :
    task => task_config
    if task_config.custom_vault_policy != null
  }

  backend   = var.nomad_datacenter.vault_jwt_path
  role_name = vault_policy.custom_application_policy[each.key].name
  token_policies = [
    var.nomad_datacenter.default_workload_vault_policy,
    vault_policy.custom_application_policy[each.key].name,
  ]

  bound_claims = {
    nomad_job_id    = var.job_name
    nomad_task      = each.key
    nomad_namespace = var.nomad_namespace
  }

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

# Create vault policy for deployment
resource "vault_policy" "terraform_policy" {
  name = local.vault_terraform_policy_role

  policy = <<EOF
# Allow tokens to look up their own properties
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

# Allow a token to look up its own capabilities on a path
path "sys/capabilities-self" {
    capabilities = ["update"]
}

# Provide privileges for Terraform to be able to create a vault token
# as per https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/token
path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
%{if local.enable_nomad_integration}
# Allow generation of consul token using assigned consul policy
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.deployment[0].name}"
{
  capabilities = ["read"]
}

# Allow generation of nomad token using assigned consul policy
path "${var.nomad_static_tokens.nomad_engine_mount_path}/creds/${vault_nomad_secret_role.deployment[0].role}"
{
  capabilities = ["read"]
}

# Allow writing to secrets
path "${module.base_secret_path.data}/*"
{
  capabilities = [ "read", "list", "create", "update", "delete" ]
}
# Allow managing service secrets
path "${module.base_secret_path.mount_path}/*"
{
  capabilities = [ "read", "update", "create" ]
}
path "${module.base_secret_path.metadata}/*"
{
  capabilities = [ "read", "update", "create" ]
}
%{endif}
# Allow reading config secret
path "${module.deployment_secret_path.data}"
{
  capabilities = [ "read", "list" ]
}
# Allow reading AWS Secrets
path "${var.vault_cluster.service_deployment_mount_path}/data/${var.vault_cluster.terraform_aws_credential_secret_path}"
{
  capabilities = [ "read", "list" ]
}

${var.additional_vault_deployment_policy != null ? var.additional_vault_deployment_policy : ""}
EOF
}
