resource "vault_pki_secret_backend_cert" "server_cert" {
  backend = var.vault_adm_pki_backend
  name    = var.vault_adm_pki_role

  common_name = "${var.hostname}.${var.vault_domain}"
  ip_sans = [
    "127.0.0.1",
    var.ip_address,
  ]
  alt_names = [
    var.vault_domain,
  ]
  revoke = true

  provider = vault.vault-adm
}
