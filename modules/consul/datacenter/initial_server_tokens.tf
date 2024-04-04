resource "vault_kv_secret_v2" "static_token" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "${var.datacenter}/consul_tokens"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      server_token         = ""
      server_service_token = ""
    }
  )

  lifecycle {
    ignore_changes = [ data_json ]
  }
}
