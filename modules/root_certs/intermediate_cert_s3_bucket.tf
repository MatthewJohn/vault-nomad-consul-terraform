resource "aws_s3_bucket" "intermediate_ca_certs" {
  bucket = "intermediate-ca-certs"
}

resource "aws_s3_bucket_versioning" "intermediate_ca_certs" {
  bucket = aws_s3_bucket.intermediate_ca_certs.id

  versioning_configuration {
    status = "Enabled"
  }
}

