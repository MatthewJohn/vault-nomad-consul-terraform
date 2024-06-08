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

resource "vault_mount" "admin_secrets" {
  path        = "admin_secrets_kv"
  type        = "kv-v2"
  description = "Admin Secrets KV store"
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
    ignore_changes = [data_json]
  }
}

data "http" "freeipa_root_cert" {
  url = "http://freeipa.dock.local/ipa/config/ca.crt"

  request_headers = {
    Accept = "text/plain"
  }
}


# Secret for FreeIPA CA
resource "vault_kv_secret_v2" "service_freeipa_ca" {
  mount               = vault_mount.service_secrets.path
  name                = "common/freeipa/ca"
  cas                 = 1
  delete_all_versions = true

  data_json = jsonencode(
    {
      pem = data.http.freeipa_root_cert.response_body
    }
  )
}

