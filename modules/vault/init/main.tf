# Run
#ssh -tt docker-connect@vault-1.dock.local docker exec -ti -e VAULT_CACERT=/vault/ssl/root-ca.pem vault vault operator init -key-shares=1 -key-threshold=1
#echo "h+F4ULyo3X1AA9LI1L6txDVRE6NwityriJhRwizcnIQ=" | ssh -tt docker-connect@vault-1.dock.local docker exec -ti -e VAULT_CACERT=/vault/ssl/root-ca.pem vault vault operator unseal

locals {
  bucket_name = "${var.cluster_name}-vault-init"
  vault_bootstrap_path = "${var.cluster_name}/vault/bootstrap"
}

# Create bucket for unseal tokens
resource "aws_s3_bucket" "vault_unseal" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "vault_unseal" {
  bucket = aws_s3_bucket.vault_unseal.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "vault_kv_secret_v2" "root_token_init" {
  mount               = "admin-terraform"
  name                = local.vault_bootstrap_path
  cas                 = 1
  delete_all_versions = false
  data_json = jsonencode(
    {
      ca_cert      = ""
      root_token   = ""
      bootstrapped = false
    }
  )

  lifecycle {
    ignore_changes = [ data_json ]
  }

  provider = vault.vault-adm
}

data "vault_kv_secret_v2" "root_token" {
  mount               = "admin-terraform"
  name                = local.vault_bootstrap_path

  depends_on = [
    vault_kv_secret_v2.root_token_init
  ]

  provider = vault.vault-adm
}

data "external" "init_vault" {
  program = [
    "bash",
    "${path.module}/init.sh",
    var.vault_host,
    var.host_ssh_username,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    aws_s3_bucket.vault_unseal.bucket,
    "vault-root.json",
    var.initial_run == true ? "1" : "0"
  ]
}

resource "vault_kv_secret_v2" "root_token" {
  mount               = "admin-terraform"
  name                = local.vault_bootstrap_path
  cas                 = 1
  delete_all_versions = false
  data_json = jsonencode(
    {
      ca_cert      = data.external.init_vault.result.ca_cert
      root_token   = data.external.init_vault.result.root_token
      bootstrapped = true
    }
  )

  provider = vault.vault-adm

  depends_on = [
    vault_kv_secret_v2.root_token_init
  ]
}
