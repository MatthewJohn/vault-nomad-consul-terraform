resource "consul_acl_policy" "traefik" {
  name        = "nomad-job-${var.nomad_region.name}-traefik"
  datacenters = [
    var.consul_datacenter.name
  ]
  rules       = <<-RULE
service_prefix "" {
  policy = "read"
}

service "traefik-http" {
  policy = "write"
}

RULE
}

resource "vault_consul_secret_backend_role" "traefik" {
  name    = "nomad-job-${var.nomad_region.name}-traefik"
  backend = var.consul_datacenter.consul_engine_mount_path

  consul_policies = [
    consul_acl_policy.traefik.name
  ]
}

resource "vault_policy" "traefik" {
  name = "nomad-job-${var.nomad_region.name}-traefik"

  policy = <<EOF
# Generate token for nomad server using consul engine role
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.traefik.name}" {
  capabilities = ["read"]
}

# Allow access to read root CA
path "${var.consul_root_cert.pki_mount_path}/cert/ca"
{
  capabilities = ["read"]
}
EOF
}
