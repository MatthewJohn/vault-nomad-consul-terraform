resource "vault_mount" "service_secrets" {
  path        = "service_secrets_kv"
  type        = "kv-v2"
  description = "Service Secrets KV store"
}