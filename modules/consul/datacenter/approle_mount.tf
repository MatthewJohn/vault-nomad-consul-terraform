
resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle-consul-${var.datacenter}"
}
