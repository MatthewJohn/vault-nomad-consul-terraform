
data "external" "root_ca" {
  program = [
    "bash",
    "${path.module}/generate_root_ca.sh",
    var.consul_binary,
    var.bucket_name,
    var.bucket_prefix,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint
  ]

  depends_on = [
    aws_s3_bucket.root_ca_certs
  ]
}
