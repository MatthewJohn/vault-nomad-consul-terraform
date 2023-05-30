
locals {
  vault_server_role   = "nomad-server-${var.region}"
  vault_server_policy = "nomad-server-${var.region}"
}

resource "vault_policy" "server_policy" {

  name = local.vault_server_policy

  policy = <<EOF
# Allow creating tokens under "nomad-cluster" token role. The token role name
# should be updated if "nomad-cluster" is not used.
path "auth/token/create/${local.vault_server_role}" {
  capabilities = ["update"]
}

# Allow looking up "nomad-cluster" token role. The token role name should be
# updated if "nomad-cluster" is not used.
path "auth/token/roles/${local.vault_server_role}" {
  capabilities = ["read"]
}

# Allow looking up the token passed to Nomad to validate # the token has the
# proper capabilities. This is provided by the "default" policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow looking up incoming tokens to validate they have permissions to access
# the tokens they are requesting. This is only required if
# `allow_unauthenticated` is set to false.
path "auth/token/lookup" {
  capabilities = ["update"]
}

# Allow revoking tokens that should no longer exist. This allows revoking
# tokens for dead tasks.
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}

# Allow checking the capabilities of our own token. This is used to validate the
# token upon startup. Note this requires update permissions because the Vault API
# is a POST
path "sys/capabilities-self" {
  capabilities = ["update"]
}

# Allow our own token to be renewed.
path "auth/token/renew-self" {
  capabilities = ["update"]
}

EOF
}

resource "vault_token_auth_backend_role" "server_role" {
  role_name = local.vault_server_role
  #allowed_policies         = ["dev", "test"]
  #disallowed_policies      = ["default"]
  allowed_policies_glob    = ["nomad-job-${var.region}-*"]
  #disallowed_policies_glob = []
  orphan                 = true
  token_period           = 7 * 24 * 60 * 60 # 7 days
  renewable              = true
  token_explicit_max_ttl = 14 * 24 * 60 * 60 # 14 days
  path_suffix            = "nomad-service-${var.region}-"
}
