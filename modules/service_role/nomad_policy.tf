

locals {
  nomad_namespace_capabilities = concat(["submit-job", "dispatch-job"], var.additional_nomad_namespace_capabilities)
}

resource "nomad_acl_policy" "this" {
  name        = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"

  rules_hcl   = <<EOT
namespace "${var.nomad_namespace}" {
  policy       = "read"
  capabilities = ${jsonencode(local.nomad_namespace_capabilities)}
}

${var.additional_nomad_policy}
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