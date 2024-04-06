# resource "vault_approle_auth_backend_role" "deployment" {
#   backend        = var.nomad_region.approle_mount_path
#   role_name      = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
#   token_policies = [
#     # Policies provided to deployment role
#     # to perform actions in terraform to perform deployment
#     vault_policy.deployment_policy.name,
#   ]
# }

# resource "vault_approle_auth_backend_role_secret_id" "deployment" {
#   backend   = var.nomad_region.approle_mount_path
#   role_name = vault_approle_auth_backend_role.deployment.role_name

#   #   metadata = jsonencode(
#   #     {
#   #     }
#   #   )
# }

# # Create vault auth role to allow the token
# # to pass the role to nomad for the application
# resource "vault_token_auth_backend_role" "deployment" {
#   role_name              = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
#   allowed_policies       = [vault_policy.application_policy.name]
#   orphan                 = true
#   token_period           = "86400"
#   renewable              = true
#   path_suffix            = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
# }