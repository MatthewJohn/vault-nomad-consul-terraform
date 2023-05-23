
resource "vault_token" "consul_template" {
  policies = [var.datacenter.agent_consul_template_policy]

  period = 356 * 24 * 60 * 60

  metadata = {
    "purpose" = "Consul Certs ${var.datacenter.name}"
  }
}
