
# Create bucket for unseal tokens
resource "aws_s3_bucket" "nomad_unseal" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "nomad_unseal" {
  bucket = aws_s3_bucket.nomad_unseal.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "external" "init_nomad" {
  program = [
    "bash",
    "${path.module}/init.sh",
    var.nomad_host.docker_host,
    var.nomad_host.docker_username,
    var.nomad_host.nomad_https_port,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    aws_s3_bucket.nomad_unseal.bucket,
    "nomad-bootstrap.json",
    var.initial_run == true ? "1" : "0"
  ]
}
