resource "vault_kv_secret_v2" "this" {
  mount               = var.vault_cluster.consul_static_mount_path
  name                = "harbor/${var.name}"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      hostname = var.harbor_hostname
      username = harbor_robot_account.system.full_name
      password = random_password.password.result
    }
  )
}