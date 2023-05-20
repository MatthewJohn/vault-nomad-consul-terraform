# Run
#ssh -tt docker-connect@vault-1.dock.local docker exec -ti -e VAULT_CACERT=/vault/ssl/root-ca.pem vault vault operator init -key-shares=1 -key-threshold=1
#echo "h+F4ULyo3X1AA9LI1L6txDVRE6NwityriJhRwizcnIQ=" | ssh -tt docker-connect@vault-1.dock.local docker exec -ti -e VAULT_CACERT=/vault/ssl/root-ca.pem vault vault operator unseal

# Create bucket for unseal tokens
resource "aws_s3_bucket" "vault_unseal" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "vault_unseal" {
  bucket = aws_s3_bucket.vault_unseal.id

  versioning_configuration {
    status = "Enabled"
  }
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
