resource "vault_jwt_auth_backend" "workload_identity" {
  path        = "jwt_nomad_${var.region.name}_${var.datacenter}"
  type        = "jwt"
  description = "Nomad JWT auth backend for workload identities - ${var.region.name}_${var.datacenter}"

  jwks_url = "${var.region.address}/.well-known/jwks.json"
  #oidc_discovery_url = "${local.server_address}/.well-known/jwks.json"
  # @TODO Can this be set?
  #bound_issuer       = local.server_address
  jwt_supported_algs = ["EdDSA"]

  jwks_ca_pem = var.root_cert.public_key

  # @TODO To configure, if necessary
  #default_role = ""
}