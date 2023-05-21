resource "vault_mount" "consul_static" {
  path        = "consul_static"
  type        = "kv-v2"
  description = "Store for static consul tokens"
}