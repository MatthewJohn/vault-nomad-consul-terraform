# Token for consul agent service registration
resource "consul_acl_policy" "agent_service_role" {

  name = "consul-server-service-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
service_prefix "consul-" {
   policy = "write"
}

service "node_exporter" {
   policy = "write"
}
EOF
}

resource "consul_acl_token" "agent_service_role" {
  description = "consul-server-service-${var.datacenter.name}"
  policies = ["${consul_acl_policy.agent_service_role.name}"]
  local = true
}

data "consul_acl_token_secret_id" "agent_service_role" {
  accessor_id = consul_acl_token.agent_service_role.id
}

resource "aws_s3_object" "consul_server_service_token" {
  bucket  = var.datacenter.consul_server_service_token.bucket
  key     = var.datacenter.consul_server_service_token.key
  content = data.consul_acl_token_secret_id.agent_service_role.secret_id

  # Force text/plain content type to force terraform to read the content
  content_type = "text/plain"

  lifecycle {
    ignore_changes = [content]
  }
}
