

locals {
  consul_service_name = "nomad-job-${var.name}"
}

resource "consul_acl_policy" "this" {
  name = local.consul_service_name

  rules = <<-RULE
key_prefix "" {
  policy = "read"
}
key_prefix "" {
  policy = "deny"
}

intention "${local.consul_service_name}"
{
  policy = "write"
}

# Allow writing the services that the service will provide
%{for consul_service in concat([local.consul_service_name], var.additional_consul_services)}
service "${local.consul_service_name}"
{
  policy = "write"
}
%{endfor}
RULE
}

resource "vault_consul_secret_backend_role" "this" {
  name    = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.this.name
  ]
}
