resource "aws_s3_bucket" "root_ca_certs" {
  bucket = "root-ca-certs"
}

resource "aws_s3_bucket_policy" "root_ca_certs" {
  bucket = aws_s3_bucket.root_ca_certs.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Resource": ["${aws_s3_bucket.root_ca_certs.arn}/*"],
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_versioning" "root_ca_certs" {
  bucket = aws_s3_bucket.root_ca_certs.id

  versioning_configuration {
    status = "Enabled"
  }
}

