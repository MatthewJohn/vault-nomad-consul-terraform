resource "consul_acl_policy" "terrareg" {
  name        = "nomad-job-${var.nomad_region.name}-terrareg"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules       = <<-RULE

RULE
}

resource "vault_consul_secret_backend_role" "terrareg" {
  name    = "nomad-job-${var.nomad_region.name}-terrareg"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.terrareg.name
  ]
}

resource "vault_policy" "terrareg" {
  name = "nomad-job-${var.nomad_region.name}-terrareg"

  policy = <<EOF
path "${var.vault_cluster.service_secrets_mount_path}/data/global/dc1/terrareg"
{
  capabilities = [ "read", "list" ]
}
EOF
}
