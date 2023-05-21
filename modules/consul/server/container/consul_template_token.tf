
resource "vault_token" "consule_template" {
  policies = [var.datacenter.agent_consul_template_policy]

  metadata = {
    "purpose" = "Consul Certs ${var.datacenter.name}"
  }
}
