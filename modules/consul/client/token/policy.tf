resource "consul_acl_policy" "this" {

  name = "consul-client-${var.datacenter.name}-${var.docker_host.hostname}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
node "consul-client-${var.datacenter.name}-${var.docker_host.hostname}" {
  policy = "write"
}
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
service "node_exporter" {
  policy = "write"
}
EOF
}