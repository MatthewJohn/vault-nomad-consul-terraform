data "aws_s3_object" "intermediate_private_key" {
  bucket = "intermediate-ca-certs"
  key    = "vault/intermediate-1.key"
}

data "aws_s3_object" "intermediate_public_key" {
  bucket = "root-ca-certs"
  key    = "vault/intermediate-1.pem"
}

data "aws_s3_object" "intermediate_ca_bundle" {
  bucket = "root-ca-certs"
  key    = "vault/intermediate-1-ca-bundle.pem"
}

data "aws_s3_object" "root_ca_cert" {
  bucket = "root-ca-certs"
  key    = "vault/root_ca.pem"
}

resource "null_resource" "ssl_trigger" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    public_key  = sha256(data.aws_s3_object.intermediate_public_key.body)
    private_key = sha256(data.aws_s3_object.intermediate_private_key.body)
  }
}