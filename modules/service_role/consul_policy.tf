

locals {
  consul_service_name = "nomad-job-${var.nomad_datacenter.name}-${var.service_name}-${var.service_name}"
}

resource "consul_acl_policy" "this" {
  name = "nomad-job-${var.nomad_region.name}-${var.service_name}"

  rules = <<-RULE
key_prefix "" {
  policy = "read"
}
key_prefix "" {
  policy = "deny"
}

# Allow writing the services that the service will provide
# and modify intentions
%{for consul_service_suffix in concat([""], var.additional_consul_services)}
service "${local.consul_service_name}${consul_service_suffix != "" ? "-${consul_service_suffix}" : ""}"
{
  policy = "write"
  intentions = "write"
}
service "nomad-job-${var.service_name}-metrics"
{
  policy = "write"
}

key_prefix "${local.consul_service_name}${consul_service_suffix != "" ? "-${consul_service_suffix}" : ""}" {
  policy = "write"
}


%{endfor}

${var.additional_consul_policy}
RULE
}


resource "vault_consul_secret_backend_role" "this" {
  name    = "nomad-deployment-job-${var.nomad_region.name}-${var.service_name}"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.this.name
  ]
}
