

resource "nomad_acl_policy" "this" {
  name        = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"

  rules_hcl   = <<EOT
namespace "default" {
  policy       = "read"
  capabilities = ["submit-job"]
}
EOT
}

resource "vault_nomad_secret_role" "this" {
  backend   = var.nomad_static_tokens.nomad_engine_mount_path
  role      = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
  type      = "client"
  global    = false

  policies  = [
    nomad_acl_policy.this.name
  ]
}