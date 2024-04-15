resource "vault_jwt_auth_backend_role" "gitlab" {
  count = var.vault_cluster.gitlab_jwt_auth_backend_path != null ? 1 : 0

  backend        = var.vault_cluster.gitlab_jwt_auth_backend_path
  role_name      = "${var.nomad_datacenter.name}-${var.service_name}"
  token_policies = [vault_policy.terraform_policy.name]

  bound_claims = {
    # project_id = var.gitlab_project_id
    project_path = var.gitlab_project_path
  }
  user_claim             = "user_email"
  role_type              = "jwt"
  token_explicit_max_ttl = 300
}