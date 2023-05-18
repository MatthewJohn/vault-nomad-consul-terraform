resource "aws_s3_bucket" "intermediate_ca_certs" {
  bucket = "intermediate-ca-certs"
}

# data "aws_iam_user" "terraform_user" {
#   user_name = "terraform"
# }

resource "aws_iam_policy" "terraform_intermediate_ca_certs_access" {
  name = "terraform-allow-intermediate-ca-certs"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicRead",
            "Effect": "Allow",
            "Principal": {
              "AWS": ["*"]
            },
            "Resource": ["${aws_s3_bucket.intermediate_ca_certs.arn}/*"],
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "terraform_intermediate_ca_certs_access" {
  user = "terraform"
  policy_arn = aws_iam_policy.terraform_intermediate_ca_certs_access.arn
}

resource "aws_s3_bucket_versioning" "intermediate_ca_certs" {
  bucket = aws_s3_bucket.intermediate_ca_certs.id

  versioning_configuration {
    status = "Enabled"
  }
}

