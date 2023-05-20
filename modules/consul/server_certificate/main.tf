
data "external" "generate_cert" {
  program = [
    "bash",
    "${path.module}/generate_server_cert.sh",
    var.consul_binary,
    var.root_ca.s3_bucket,
    var.root_ca.s3_prefix,
    var.aws_profile,
    var.aws_region,
    var.aws_endpoint,
    var.initial_run == true ? "1" : "0",
    var.ip_address,
    var.root_ca.s3_key_public_key,
    var.root_ca.s3_key_private_key,
    var.expiry_days,
    var.datacenter,
    var.root_ca.domain_name,
    var.hostname,
    join(",", var.additional_domains),
  ]

}
