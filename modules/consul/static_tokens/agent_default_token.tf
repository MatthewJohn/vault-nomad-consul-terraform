# Token for consul agent service registration
resource "consul_acl_policy" "server_dns_service_role" {

  name = "consul-server-dns-${var.datacenter.name}"

  datacenters = [var.datacenter.name]

  rules = <<EOF
## acl-policy-dns.hcl
node_prefix "" {
  policy = "read"
}
service_prefix "" {
  policy = "read"
}
# only needed if using prepared queries
query_prefix "" {
  policy = "read"
}
EOF
}

resource "consul_acl_token" "server_dns_service_role" {
  description = "consul-server-dns-${var.datacenter.name}"
  policies = ["${consul_acl_policy.server_dns_service_role.name}"]
  local = true
}

data "consul_acl_token_secret_id" "server_dns_service_role" {
  accessor_id = consul_acl_token.server_dns_service_role.id
}
