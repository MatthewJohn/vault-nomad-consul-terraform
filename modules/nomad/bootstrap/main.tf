# Create bucket for unseal tokens
locals {
  bucket_name = "${var.cluster_name}-nomad-bootstrap"
  nomad_bootstrap_path = "${var.cluster_name}/nomad/bootstrap"
}

resource "aws_s3_bucket" "nomad_unseal" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "nomad_unseal" {
  bucket = aws_s3_bucket.nomad_unseal.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "vault_kv_secret_v2" "root_token_init" {
  mount               = "admin-terraform"
  name                = local.nomad_bootstrap_path
  cas                 = 1
  delete_all_versions = false
  data_json = jsonencode(
    {
      token        = ""
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
  name                = local.nomad_bootstrap_path

  depends_on = [
    vault_kv_secret_v2.root_token_init
  ]

  provider = vault.vault-adm
}

data "external" "init_nomad" {
  program = [
    "bash",
    "${path.module}/init.sh",
    var.nomad_host.fqdn,
    var.nomad_host.username,
    "4646",
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    aws_s3_bucket.nomad_unseal.bucket,
    "nomad-bootstrap.json",
    var.initial_run == true ? "1" : "0"
  ]
}

resource "vault_kv_secret_v2" "root_token" {
  mount               = "admin-terraform"
  name                = local.nomad_bootstrap_path
  cas                 = 1
  delete_all_versions = false
  data_json = jsonencode(
    {
      token        = data.external.init_nomad.result.token
      bootstrapped = true
    }
  )

  provider = vault.vault-adm

  depends_on = [
    vault_kv_secret_v2.root_token_init
  ]
}