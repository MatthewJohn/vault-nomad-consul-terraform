resource "aws_s3_bucket" "root_ca_certs" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "root_ca_certs" {
  bucket = aws_s3_bucket.root_ca_certs.id

  versioning_configuration {
    status = "Enabled"
  }
}

