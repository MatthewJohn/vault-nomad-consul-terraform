
locals {
  vault_secret_base_path      = "${var.vault_cluster.service_secrets_mount_path}/${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.name}"
  vault_secret_base_data_path = "${var.vault_cluster.service_secrets_mount_path}/data/${var.nomad_region.name}/${var.nomad_datacenter.name}/${var.name}"
}

# Create vault policy for deployment
resource "vault_policy" "deployment_policy" {
  name = "nomad-deployment-job-${var.nomad_region.name}-${var.name}"

  policy = <<EOF
# Allow generation of consul token using assigned consul policy
path "${var.consul_datacenter.consul_engine_mount_path}/creds/${vault_consul_secret_backend_role.this.name}"
{
  capabilities = ["read"]
}

# Allow writing to secrets
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list", "create", "update", "delete" ]
}

# Allow approle to login
path "${var.nomad_region.approle_mount_path}/login"
{
  capabilities = ["update"]
}
EOF
}

# Create vault policy for application
resource "vault_policy" "application_policy" {
  name = "nomad-job-${var.nomad_region.name}-${var.name}"

  policy = <<EOF
# Allow reading of secrets for application
path "${local.vault_secret_base_data_path}/*"
{
  capabilities = [ "read", "list" ]
}
EOF
}
