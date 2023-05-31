resource "consul_acl_policy" "traefik" {
  name        = "nomad-job-${var.nomad_region.name}-hello-world"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules       = <<-RULE

RULE
}

resource "vault_consul_secret_backend_role" "traefik" {
  name    = "nomad-job-${var.nomad_region.name}-hello-world"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.traefik.name
  ]
}

resource "vault_policy" "traefik" {
  name = "nomad-job-${var.nomad_region.name}-hello-world"

  policy = <<EOF

EOF
}
