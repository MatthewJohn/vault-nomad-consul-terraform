data "aws_s3_object" "intermediate_private_key" {
  bucket = "intermediate-ca-certs"
  key    = "vault/intermediate-1.key"
}

data "aws_s3_object" "intermediate_public_key" {
  bucket = "intermediate-ca-certs"
  key    = "vault/intermediate-1.crt"
}

data "aws_s3_object" "intermediate_full_chain" {
  bucket = "intermediate-ca-certs"
  key    = "vault/intermediate-1-full-chain.crt"
}
