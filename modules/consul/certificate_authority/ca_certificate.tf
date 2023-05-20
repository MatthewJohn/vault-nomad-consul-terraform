resource "vault_pki_secret_backend_root_cert" "this" {
  backend = vault_mount.consul_pki.path

  type = "internal"

  common_name  = var.common_name
  ou           = var.ou
  organization = var.organisation

  key_bits = 4096

  depends_on = [
    vault_mount.consul_pki
  ]
}

resource "vault_pki_secret_backend_config_urls" "this" {
  backend = vault_mount.consul_pki.path

  issuing_certificates = [
    "${var.vault_cluster.address}/v1/${vault_mount.consul_pki.path}/ca",
  ]

  crl_distribution_points = [
    "${var.vault_cluster.address}/v1/${vault_mount.consul_pki.path}/crl",
  ]
}
