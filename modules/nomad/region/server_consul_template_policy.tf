# Create policy that allows consul template on nomad servers to:
# * Obtain CA certs
# * Obtain consul token
# * Renew its own token
# * Obtain Root CA cert for nomad
# * Create token for nomad server, using a token role, which species
#   the server policy that can be used for the token


resource "vault_token_auth_backend_role" "server_consul_template_role" {
  role_name = "nomad-server-consul-template-${var.region}"
  allowed_policies         = [local.vault_server_policy]
  #disallowed_policies      = ["default"]
  #allowed_policies_glob    = []
  #disallowed_policies_glob = []
  orphan                 = true
  token_period           = 7 * 24 * 60 * 60 # 7 days
  renewable              = true
  token_explicit_max_ttl = 14 * 24 * 60 * 60 # 14 days
  path_suffix            = "nomad-server-${var.region}-"
}


resource "vault_policy" "server_consul_template" {
  name = "nomad-server-consul-template-${var.region}"

  policy = <<EOF
# Access CA certs
path "${vault_mount.this.path}/issue/${vault_pki_secret_backend_role.this.name}" {
  capabilities = [ "read", "update" ]
}

# Generate token for nomad server using consul engine role
path "${var.consul_datacenter.consul_engine_mount_path}/creds/nomad-${var.region}-server-*" {
  capabilities = ["read"]
}

# Renew leases
path "sys/leases/renew" {
  capabilities = [ "update" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "${vault_auth_backend.approle.path}/login"
{
  capabilities = ["update"]
}

# Allow access to read root CA
path "${var.root_cert.pki_mount_path}/cert/ca"
{
  capabilities = ["read"]
}

# Allow creating tokens under "nomad-server" token role.
# Allow "sudo" permission so that client can create period token.
path "auth/token/create/${vault_token_auth_backend_role.server_consul_template_role.role_name}" {
  capabilities = ["update", "sudo"]
}

# Allow looking up "nomad-cluster" token role.
path "auth/token/roles/${vault_token_auth_backend_role.server_consul_template_role.role_name}" {
  capabilities = ["read"]
}

EOF
}

resource "vault_approle_auth_backend_role" "server_consul_template" {
  backend        = vault_auth_backend.approle.path
  role_name      = "nomad-server-${var.region}-consul-template"
  token_policies = [vault_policy.server_consul_template.name]
}
