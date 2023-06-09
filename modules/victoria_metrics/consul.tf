resource "consul_acl_policy" "victoria_metrics" {
  name  = "victoria-metrics"
  rules = <<-RULE
    node_prefix "" {
      policy = "read"
    }
    agent "${module.consul_client.agent_name}" {
      policy = "read"
    }
    service_prefix "" {
      policy = "read"
    }
    agent_prefix "" {
      policy = "read"
    }
  RULE
}

resource "consul_acl_token" "victoria_metrics" {
  description = "victoria_metrics"
  policies = ["${consul_acl_policy.victoria_metrics.name}"]
  local = true
}

data "consul_acl_token_secret_id" "victoria_metrics" {
  accessor_id = consul_acl_token.victoria_metrics.id
}
