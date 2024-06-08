
# Create bucket for unseal tokens
locals {
  bucket_name           = "${var.cluster_name}-consul-bootstrap"
  consul_bootstrap_path = "${var.cluster_name}/consul/bootstrap"
}

resource "aws_s3_bucket" "consul_unseal" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "consul_unseal" {
  bucket = aws_s3_bucket.consul_unseal.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "vault_kv_secret_v2" "root_token_init" {
  mount               = "admin-terraform"
  name                = local.consul_bootstrap_path
  cas                 = 1
  delete_all_versions = false
  data_json = jsonencode(
    {
      token        = ""
      bootstrapped = false
    }
  )

  lifecycle {
    ignore_changes = [data_json]
  }

  provider = vault.vault-adm
}

data "vault_kv_secret_v2" "root_token" {
  mount = "admin-terraform"
  name  = local.consul_bootstrap_path

  depends_on = [
    vault_kv_secret_v2.root_token_init
  ]

  provider = vault.vault-adm
}

data "external" "init_consul" {
  program = [
    "bash",
    "${path.module}/init.sh",
    var.docker_host.fqdn,
    var.docker_host.username,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    aws_s3_bucket.consul_unseal.bucket,
    "consul-bootstrap.json",
    var.initial_run == true ? "1" : "0"
  ]
}

resource "vault_kv_secret_v2" "root_token" {
  mount               = "admin-terraform"
  name                = local.consul_bootstrap_path
  cas                 = 1
  delete_all_versions = false
  data_json = jsonencode(
    {
      token        = data.external.init_consul.result.token
      bootstrapped = true
    }
  )

  provider = vault.vault-adm

  depends_on = [
    vault_kv_secret_v2.root_token_init
  ]
}

