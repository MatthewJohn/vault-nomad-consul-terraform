resource "vault_auth_backend" "approle" {
  type        = "approle"
  path        = "approle"
  description = "Global vault approle"
}
