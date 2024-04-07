resource "vault_mount" "service_secrets" {
  path        = "service_secrets_kv"
  type        = "kv-v2"
  description = "Service Secrets KV store"
}

resource "vault_mount" "deployment_secrets" {
  path        = "deployment_secrets_kv"
  type        = "kv-v2"
  description = "Service deployment Secrets KV store"
}

# Secret for storing Terraform s3 access key
resource "vault_kv_secret_v2" "terraform_aws_credentials" {
  mount               = vault_mount.deployment_secrets.path
  name                = "terraform/s3_credentials"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      access_key = ""
      secret_key = ""
    }
  )

  lifecycle {
    ignore_changes = [ data_json ]
  }
}
