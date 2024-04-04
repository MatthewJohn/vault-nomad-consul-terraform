resource "vault_pki_secret_backend_role" "role" {
  backend = var.vault_cluster.pki_mount_path

  name    = local.common_name

  key_type = "rsa"
  key_bits = 4096
  allowed_domains = [
    local.common_name
  ]
  allow_subdomains = true
}
