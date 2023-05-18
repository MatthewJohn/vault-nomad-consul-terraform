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

resource "null_resource" "ssl_trigger" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    public_key = sha256(data.aws_s3_object.intermediate_public_key.body)
    private_key = sha256(data.aws_s3_object.intermediate_private_key.body)
  }
}