resource "random_id" "gossip" {
  # Generates 64 hex characters
  byte_length = 32
}

resource "vault_kv_secret_v2" "gossip" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "${var.datacenter}/gossip"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      value = random_id.gossip.b64_std
    }
  )
}
