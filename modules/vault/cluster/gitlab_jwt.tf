resource "vault_jwt_auth_backend" "gitlab" {
  description         = "Gitlab JWT auth backend"
  path                = "gitlab_jwt"
  type = "jwt"
  # jwks_url = "${var.gitlab_url}/-/jwks"
  oidc_discovery_url = var.gitlab_url
  bound_issuer = var.gitlab_url
}