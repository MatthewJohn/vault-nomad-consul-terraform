resource "random_password" "harbor_password" {
  length  = 49
  special = false
}

resource "vault_kv_secret_v2" "harbor" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "harbor/nomad-client-${var.region.name}-${var.datacenter}"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      hostname = var.harbor_hostname
      username = "nomad-client-${var.region.name}-${var.datacenter}"
      password = random_password.harbor_password.result
    }
  )
}