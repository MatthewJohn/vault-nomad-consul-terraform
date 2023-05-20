# # XXX; The vault_pki_secret_backend_config_ca resource has no drift detection,
# # as the API it wraps is write-only. If this resource persists in the state
# # while Vault state is wiped underneath it, Terraform will not correctly
# # detect that it needs to be recreated.
# #
# # lifecycle.replace_triggered_by on the config_ca doesn't solve this by itself,
# # as when Vault state is wiped, vault_mount.pki is planned to be created, not
# # updated or replaced, and resource creation doesn't trigger
# # replace_triggered_by.
# #
# # To get the behavior we want, use this null_resource as a shim. It survives
# # Vault state being wiped, and plans to replace itself if the accessor ID of the
# # PKI mount changes. This replacement can be used to trigger
# # replace_triggered_by on the config_ca resource.
# resource "null_resource" "pki_backend_tracker" {
#   triggers = {
#     accessor = vault_mount.pki.accessor
#   }
# }

# resource "vault_pki_secret_backend_config_ca" "pki" {
#   lifecycle {
#     replace_triggered_by = [null_resource.pki_backend_tracker]
#   }

#   backend    = vault_mount.pki.path
#   pem_bundle = local.pki
# }

# # Vault 1.11 added new functionality in the pki backend in which there can be
# # multiple issuing CAs ("issuers") installed in one mount. Adding a new CA cert
# # now creates a new issuer, but doesn't update the backend to issue from that
# # new issuer by default. The "default_follows_latest_issuer" option preserves
# # the pre-1.11 behavior of always issuing from the last installed issuer.
# #
# # https://developer.hashicorp.com/vault/api-docs/secret/pki#notice-about-new-multi-issuer-functionality
# # https://developer.hashicorp.com/vault/api-docs/secret/pki#default_follows_latest_issuer
# #
# # The config/issuers endpoint requires that we provide an issuer to set as the
# # default in its "issuer" field, so first, figure out what the current default
# # is and just pass it back. We can't do this until an issuer is actually
# # installed, so we depends_on the pki config CA being installed. This is fine as
# # long as we're not changing the CA in the same run we're first applying this
# # config, as that would create a new issuer which isn't the default and then
# # that issuer would get orphaned. Make sure this resource is applied on the
# # current CA before rotating to a new CA.
# data "vault_generic_secret" "pki_default_issuer" {
#   depends_on = [vault_pki_secret_backend_config_ca.pki]

#   path = "${vault_mount.this.path}/issuer/default"
# }

# resource "vault_generic_endpoint" "pki_config_issuers" {
#   path = "${vault_mount.this.path}/config/issuers"
#   data_json = jsonencode({
#     default                       = data.vault_generic_secret.pki_default_issuer.data.issuer_id,
#     default_follows_latest_issuer = true,
#   })
#   disable_delete = true
# }