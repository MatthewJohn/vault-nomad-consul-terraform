resource "vault_ldap_auth_backend" "ldap" {
  count = var.ldap != null ? 1 : 0

  path        = "ldap"
  url         = var.ldap.url
  userdn      = var.ldap.userdn
  userattr    = var.ldap.userattr
  userfilter  = var.ldap.userfilter
  groupdn     = var.ldap.groupdn
  groupfilter = var.ldap.groupfilter
  certificate = var.ldap.certificate
  discoverdn  = false
}