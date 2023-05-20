
data "external" "root_ca" {
  program = [
    "bash",
    "${path.module}/generate_root_ca.sh",
    var.consul_binary,
    var.bucket_name,
    var.bucket_prefix,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    var.common_name,
    var.domain,
    join(",", var.additional_domains),
    var.expiry_days,
    var.initial_run == true ? "1" : "0",
  ]

  depends_on = [
    aws_s3_bucket.root_ca_certs
  ]
}
