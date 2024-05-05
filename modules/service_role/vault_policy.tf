
locals {
  vault_terraform_policy_role = local.enable_nomad_integration ? "nomad-terraform-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.service_name}" : "terraform-${var.service_name}"
  vault_nomad_policy_role     = local.enable_nomad_integration ? "nomad-submit-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.service_name}" : null
  vault_job_policy_role       = local.enable_nomad_integration ? "nomad-job-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.service_name}" : null
  vault_secret_path           = local.enable_nomad_integration ? "${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.service_name}" : "pipelines/${var.gitlab_project_path}"
  vault_secret_base_path      = "${var.vault_cluster.service_secrets_mount_path}/${local.vault_secret_path}"
  vault_secret_base_data_path = "${var.vault_cluster.service_secrets_mount_path}/data/${local.vault_secret_path}"
  deployment_secret_path      = local.enable_nomad_integration ? "konvad/services/${local.vault_secret_path}" : local.vault_secret_path
}

# Policy that will be attached to the application
resource "vault_policy" "application_policy" {
  count = local.enable_nomad_integration ? 1 : 0

  name = local.vault_job_policy_role

  policy = <<EOF
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

# Allow generation of consul token using assigned consul policy
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.this[0].name}"
{
  capabilities = ["read"]
}

# Allow reading secrets
path "${local.vault_secret_base_path}/*"
{
  capabilities = [ "read", "list" ]
}
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list" ]
}

${var.additional_vault_application_policy}
EOF
}

# Policy for token that will be provided to nomad to perform deployment
resource "vault_policy" "nomad_policy" {
  count = local.enable_nomad_integration ? 1 : 0

  name = local.vault_nomad_policy_role

  policy = <<EOF
path "auth/token/lookup-self"
{
  capabilities = [ "read" ]
}

# Allow reading
path "${local.vault_secret_base_path}/*"
{
  capabilities = [ "read", "list" ]
}
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list" ]
}

${var.additional_nomad_vault_policy}

EOF
}

# Create vault auth role to allow the token
# to pass the role to nomad for the application
resource "vault_token_auth_backend_role" "nomad" {
  count = local.enable_nomad_integration ? 1 : 0

  role_name = local.vault_nomad_policy_role

  allowed_policies = [
    vault_policy.nomad_policy[count.index].name,
    vault_policy.application_policy[count.index].name,
  ]
  orphan       = true
  token_period = "86400"
  renewable    = true
  path_suffix  = local.vault_nomad_policy_role
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
# Allow creation of token using role
path "auth/token/create/${vault_token_auth_backend_role.nomad[0].role_name}"
{
  capabilities = [ "update" ]
}

# Allow generation of consul token using assigned consul policy
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.this[0].name}"
{
  capabilities = ["read"]
}

# Allow generation of nomad token using assigned consul policy
path "${var.nomad_static_tokens.nomad_engine_mount_path}/creds/${vault_nomad_secret_role.this[0].role}"
{
  capabilities = ["read"]
}

# Allow writing to secrets
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list", "create", "update", "delete" ]
}
%{endif}
# Allow reading config secret
path "${var.vault_cluster.service_deployment_mount_path}/data/${local.deployment_secret_path}"
{
  capabilities = [ "read", "list" ]
}
%{if local.enable_nomad_integration}
# Allow managing secret meta
path "${var.vault_cluster.service_secrets_mount_path}/metadata/${local.vault_secret_path}/*"
{
  capabilities = [ "read", "update", "create" ]
}
%{endif}
# Allow reading AWS Secrets
path "${var.vault_cluster.service_deployment_mount_path}/data/${var.vault_cluster.terraform_aws_credential_secret_path}"
{
  capabilities = [ "read", "list" ]
}

${var.additional_vault_deployment_policy}
EOF
}
