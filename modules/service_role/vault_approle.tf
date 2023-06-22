
resource "vault_approle_auth_backend_role" "deployment" {
  backend        = var.nomad_region.approle_mount_path
  role_name      = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
  token_policies = [
    # Policies provided to deployment role
    # to perform actions in terraform to perform deployment
    vault_policy.deployment_policy.name,
    # Add vault policy for application, to allow the token
    # to pass the role to nomad for the application
    vault_policy.application_policy.name
  ]
}


resource "vault_approle_auth_backend_role_secret_id" "deployment" {
  backend   = var.nomad_region.approle_mount_path
  role_name = vault_approle_auth_backend_role.deployment.role_name

  #   metadata = jsonencode(
  #     {
  #     }
  #   )
}
