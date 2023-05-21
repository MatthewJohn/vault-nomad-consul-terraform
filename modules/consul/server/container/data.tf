data "dns_a_record_set" "consul_cluster" {
  host = var.datacenter.common_name
}

locals {
  boostrap_count = length(data.dns_a_record_set.consul_cluster.addrs)
}
