
resource "vault_approle_auth_backend_role" "deployment" {
  backend        = var.nomad_region.approle_mount_path
  role_name      = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
  token_policies = [vault_policy.deployment_policy.name]
}


resource "vault_approle_auth_backend_role_secret_id" "deployment" {
  backend   = var.nomad_region.approle_mount_path
  role_name = vault_approle_auth_backend_role.deployment.role_name

  #   metadata = jsonencode(
  #     {
  #     }
  #   )
}
