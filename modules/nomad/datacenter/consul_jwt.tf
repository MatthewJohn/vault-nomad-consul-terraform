resource "consul_acl_auth_method" "jwt" {
  name          = "jwt_nomad_${var.region.name}_${var.datacenter}"
  type          = "jwt"
  description   = "JWT Auth token for nomad"
  max_token_ttl = "1h"

  config_json = jsonencode({
    BoundAudiences = [
      "consul.io"
    ]
    ClaimMappings = {
      nomad_job_id    = "nomad_job_id",
      nomad_namespace = "nomad_namespace"
      nomad_service   = "nomad_service"
      nomad_task      = "nomad_task"
    }
    JWKSURL = "${var.region.address}/.well-known/jwks.json"
    JWTSupportedAlgs = [
        "RS256"
    ]
    JWKSCACert = var.root_cert.public_key
  })
}

resource "consul_acl_binding_rule" "service" {
  auth_method = consul_acl_auth_method.jwt.name
  description = "Binding rule for services registered from Nomad"
  # @TODO Fix this selector
  #selector    = "\"nomad_service\" in value and \"nomad-job-${var.datacenter}-$${value.nomad_job_id}\" in value.nomad_service"
  selector    = "\"nomad_service\" in value"
  bind_type   = "service"
  bind_name   = "$${value.nomad_service}"
}

resource "consul_acl_policy" "workload_identity_task" {
  name = "default-identity-${var.region.name}-${var.datacenter}"

  rules = <<-RULE
key_prefix "" {
  policy = "read"
}

service_prefix "" {
  policy = "read"
}
RULE
}

resource "consul_acl_role" "task" {
  name = consul_acl_policy.workload_identity_task.name
  description = "Default workload identity role for nomad in ${var.region.name} ${var.datacenter}"
  policies = [
    consul_acl_policy.workload_identity_task.id
  ]
}

resource "consul_acl_binding_rule" "task" {
  auth_method = consul_acl_auth_method.jwt.name
  description = "Binding rule for tasks registered from Nomad"
  selector    = "\"nomad_service\" not in value"
  bind_type   = "role"
  bind_name   = consul_acl_role.task.name
}