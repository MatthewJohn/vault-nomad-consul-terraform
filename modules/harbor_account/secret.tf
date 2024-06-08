data "vault_kv_secret_v2" "this" {
  mount               = var.harbor_account.secret_mount
  name                = var.harbor_account.secret_name
}