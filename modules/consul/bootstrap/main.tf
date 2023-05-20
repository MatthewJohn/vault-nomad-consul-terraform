
# Create bucket for unseal tokens
resource "aws_s3_bucket" "consul_unseal" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "consul_unseal" {
  bucket = aws_s3_bucket.consul_unseal.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "external" "init_consul" {
  program = [
    "bash",
    "${path.module}/init.sh",
    var.consul_host,
    var.host_ssh_username,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    aws_s3_bucket.consul_unseal.bucket,
    "consul-boostrap.json",
    var.initial_run == true ? "1" : "0"
  ]
}
