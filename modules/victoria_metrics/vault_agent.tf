# Generate app role for vault agent, which has permissions to generate secret for victoriametrics

resource "vault_policy" "this" {
  name = "victoria-metrics"

  policy = <<EOF
# Access prometheus stats
path "/sys/metrics" {
  capabilities = ["read"]
}
EOF
}

resource "vault_approle_auth_backend_role" "this" {
  backend = var.vault_cluster.approle_mount_path

  role_name      = "victoria-metrics"
  token_policies = [vault_policy.this.name]

  token_ttl     = 5 * 60
  token_max_ttl = 5 * 60
}

data "vault_approle_auth_backend_role_id" "this" {
  backend   = var.vault_cluster.approle_mount_path
  role_name = vault_approle_auth_backend_role.this.role_name
}

resource "vault_approle_auth_backend_role_secret_id" "this" {
  backend   = var.vault_cluster.approle_mount_path
  role_name = vault_approle_auth_backend_role.this.role_name

  metadata = jsonencode(
    {
      "node_name" = "victoria-metrics"
      "hostname"  = var.hostname
    }
  )
}

module "vault_agent" {
  source = "../vault/agent"

  hostname       = var.hostname
  domain_name    = var.domain_name
  vault_cluster  = var.vault_cluster
  container_name = "vault-agent-victoria-metrics"

  base_directory = "/vault-agent-victoria-metrics"

  app_role_id         = data.vault_approle_auth_backend_role_id.this.role_id
  app_role_secret     = vault_approle_auth_backend_role_secret_id.this.secret_id
  app_role_mount_path = var.vault_cluster.approle_mount_path

  docker_username = var.docker_username
  docker_host     = var.docker_host
  docker_ip       = var.docker_ip
}