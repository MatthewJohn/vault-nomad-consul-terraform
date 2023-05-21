resource "vault_identity_oidc_key" "oidc_key" {
  name      = "consul-cluster-${var.datacenter}"
  algorithm = "RS256"

  allowed_client_ids = [
    "consul-cluster-${var.datacenter}"
  ]
}

#vault write identity/oidc/role/oidc-role-1 ttl=12h key="oidc-key-1" client_id="consul-cluster-dc1" template='{"consul": {"hostname": "consul-client" } }'

resource "vault_identity_oidc_role" "role" {
  name = "consul-cluster-${var.datacenter}"
  key  = vault_identity_oidc_key.oidc_key.name

  ttl       = (12 * 60 * 60)  # "12h"
  client_id = "consul-cluster-${var.datacenter}"

  template = "{\"consul\": {\"hostname\": \"consul-client\" } }"
}

# resource "vault_policy" "oidc" {
#   name = "oidc-consul-cluster-${var.datacenter}"

#   policy = <<EOF
# {
#     "path": {
#         "identity/oidc/token/${vault_identity_oidc_role.role.name}": {
#             "policy": "read"
#         }
#     }
# }
# EOF
# }
