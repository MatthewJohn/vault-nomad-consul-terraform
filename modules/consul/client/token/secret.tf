resource "vault_kv_secret_v2" "this" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "${var.datacenter.name}/agent/${var.docker_host.hostname}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = data.consul_acl_token_secret_id.this.secret_id
    }
  )
}
