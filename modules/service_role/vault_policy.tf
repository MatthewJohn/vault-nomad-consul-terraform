
locals {
  vault_terraform_policy_role  = "nomad-terraform-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.service_name}"
  vault_nomad_policy_role      = "nomad-submit-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.service_name}"
  vault_job_policy_role        = "nomad-job-${var.nomad_region.name}-${var.nomad_datacenter.name}-${var.service_name}"
  vault_secret_base_path       = "${var.vault_cluster.service_secrets_mount_path}/${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.service_name}"
  vault_secret_base_data_path  = "${var.vault_cluster.service_secrets_mount_path}/data/${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.service_name}"
}

# Policy that will be attached to the application
resource "vault_policy" "application_policy" {
  name = local.vault_job_policy_role

  policy = <<EOF
path "auth/token/lookup-self" {
    capabilities = ["read"]
}

${var.additional_vault_application_policy}
EOF
}

# Policy for token that will be provided to nomad to perform deployment
resource "vault_policy" "nomad_policy" {
  name = local.vault_nomad_policy_role

  policy = <<EOF
path "auth/token/lookup-self"
{
  capabilities = [ "read" ]
}

# Allow generation of consul token using assigned consul policy
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.this.name}"
{
  capabilities = ["read"]
}

# Allow generation of nomad token using assigned consul policy
path "${var.nomad_static_tokens.nomad_engine_mount_path}/creds/${vault_nomad_secret_role.this.role}"
{
  capabilities = ["read"]
}

# Allow reading
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list" ]
}

EOF
}

# Create vault auth role to allow the token
# to pass the role to nomad for the application
resource "vault_token_auth_backend_role" "nomad" {
  role_name              = local.vault_nomad_policy_role

  allowed_policies       = [
    vault_policy.nomad_policy.name
  ]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  path_suffix            = local.vault_nomad_policy_role
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

# Allow creation of token using role
path "auth/token/create/${vault_token_auth_backend_role.nomad.role_name}"
{
  capabilities = [ "update" ]
}

# Allow writing to secrets
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list", "create", "update", "delete" ]
}

${var.additional_vault_deployment_policy}
EOF
}

resource "vault_approle_auth_backend_role" "terraform" {
  backend        = var.nomad_region.approle_mount_path
  role_name      = local.vault_terraform_policy_role
  token_policies = [
    # Policies provided to deployment role
    # to perform actions in terraform to perform deployment
    vault_policy.terraform_policy.name,
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "terraform" {
  backend   = var.nomad_region.approle_mount_path
  role_name = vault_approle_auth_backend_role.terraform.role_name
}

output "test" {
  value = {
    role = vault_approle_auth_backend_role.terraform.role_id
    secret_id = nonsensitive(vault_approle_auth_backend_role_secret_id.terraform.secret_id)
  }
}