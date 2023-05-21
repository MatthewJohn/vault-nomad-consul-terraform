# Create empty tokens to allow template to pass, which will be overriden in other modules
resource "vault_kv_secret_v2" "agent_token" {
  mount = var.vault_cluster.consul_static_mount_path
  name  = "${var.datacenter.name}/agent-tokens/${var.hostname}"

  data_json = jsonencode(
    {
      token = ""
    }
  )
}