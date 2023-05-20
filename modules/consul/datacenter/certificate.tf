resource "vault_pki_secret_backend_root_cert" "this" {
  backend = vault_mount.this.path

  type = "internal"

  common_name          = "${var.datacenter}.${var.consul_domain} Intermediate Authority"

  key_bits             = 4096
  exclude_cn_from_sans = true

  depends_on = [
    vault_mount.consul_pki
  ]
}

