data "dns_a_record_set" "nomad_cluster" {
  host = var.datacenter.client_dns
}

locals {
  bootstrap_count = ceil(length(data.dns_a_record_set.nomad_cluster.addrs) / 2)
}
