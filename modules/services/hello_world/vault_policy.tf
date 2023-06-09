resource "consul_acl_policy" "this" {
  name        = "nomad-job-${var.nomad_region.name}-hello-world"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules       = <<-RULE

RULE
}

resource "vault_consul_secret_backend_role" "this" {
  name    = "nomad-job-${var.nomad_region.name}-hello-world"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.this.name
  ]
}

resource "vault_policy" "this" {
  name = "nomad-job-${var.nomad_region.name}-hello-world"

  policy = <<EOF

EOF
}
