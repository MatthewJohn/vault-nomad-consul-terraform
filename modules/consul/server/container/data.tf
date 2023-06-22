data "dns_a_record_set" "consul_cluster" {
  host = var.datacenter.common_name
}

locals {
  bootstrap_count = ceil(length(data.dns_a_record_set.consul_cluster.addrs) / 2)
}

data "aws_s3_object" "consul_server_token" {
  bucket = var.datacenter.consul_server_token.bucket
  key    = var.datacenter.consul_server_token.key
}

data "aws_s3_object" "consul_server_service_token" {
  bucket = var.datacenter.consul_server_service_token.bucket
  key    = var.datacenter.consul_server_service_token.key
}
