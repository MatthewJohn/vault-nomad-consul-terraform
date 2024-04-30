resource "vault_policy" "terraform" {
  name = var.terraform_policy_name

  policy = <<EOF
# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# List ACL policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create tokens/roles
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Update vault deployment secrets
path "${vault_mount.deployment_secrets.path}/*"
{
  capabilities = ["list", "read", "create", "update", "delete"]
}

# List enabled secrets engines
path "sys/mounts"
{
  capabilities = ["read", "list"]
}

# Manage PKI secrets engine
path "pki/*"
{
  capabilities = ["create", "read", "update", "list"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}

# Permission to create victoria metrifcs token
path "sys/policies/acl/victoria-metrics"
{
  capabilities = [ "read", "create", "update", "delete" ]
}

#########################
# Permissions for Consul CA
path "sys/mounts/pki"
{
  capabilities = ["read", "list"]
}
# Revoke certificates
path "pki/revoke"
{
  capabilities = ["update"]
}

# Add roles for root cert
path "pki/roles/*"
{
  capabilities = ["read", "create", "update"]
}

# Sign intermediate certificates
path "pki/root/sign-intermediate"
{
  capabilities = ["update"]
}

# Consul connect
## CA
path "sys/mounts/pki_connect"
{
  capabilities = ["create", "update", "read"]
}

# Access to create harbor tokens
path "consul_static/data/harbor/*"
{
  capabilities = ["read", "update", "create", "delete", "list"]
}
path "consul_static/metadata/harbor/*"
{
  capabilities = ["read", "update", "create", "delete", "list"]
}

%{for datacenter in var.consul_datacenters}
path "sys/mounts/pki_int_consul_${datacenter}"
{
  capabilities = ["read", "list", "create", "update"]
}

# Generate intermediate CAs
path "pki_int_consul_${datacenter}/issuers/generate/intermediate/internal"
{
  capabilities = ["update"]
}

# Set default issuer for cert
path "pki_int_consul_${datacenter}/config/issuers"
{
  capabilities = ["update", "read"]
}

# Set self-signed certificate
path "pki_int_consul_${datacenter}/intermediate/set-signed"
{
  capabilities = ["update"]
}

# Create/view/delete roles
path "pki_int_consul_${datacenter}/roles/*"
{
  capabilities = ["update", "read", "delete"]
}

# Server policies
path "sys/policies/acl/agent-consul-template-${datacenter}"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Client policies
path "sys/policies/acl/consul-client-consul-template-${datacenter}"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Write static tokens
path "consul_static/data/${datacenter}/agent-tokens/*"
{
  capabilities = ["read", "update", "create", "delete", "list"]
}

path "consul_static/metadata/${datacenter}/agent-tokens/*"
{
  capabilities = ["read", "update", "create", "delete", "list"]
}

# Manage consul secret mount
path "sys/mounts/consul-${datacenter}"
{
  capabilities = ["create", "read", "update", "list", "delete" ]
}
path "consul-${datacenter}/config/access"
{
  capabilities = ["update", "read"]
}

# Create consul role for servers
path "consul-${datacenter}/roles/consul-server-role"
{
  capabilities = ["create", "read", "delete", "update"]
}
path "consul-${datacenter}/roles/consul-server-service-role"
{
  capabilities = ["create", "read", "delete", "update"]
}

# Create consul role for clients
path "consul-${datacenter}/roles/consul-client-role"
{
  capabilities = ["create", "read", "delete", "update"]
}

# Create role and read token for terraform role
path "consul-${datacenter}/roles/terraform"
{
  capabilities = ["create", "read", "delete", "update"]
}
path "consul-${datacenter}/creds/terraform"
{
  capabilities = ["read"]
}

%{for nomad_region in keys(var.nomad_regions)}
path "consul-${datacenter}/roles/nomad-${nomad_region}-server-*"
{
  capabilities = ["create", "read", "delete", "update"]
}

path "consul-${datacenter}/roles/nomad-job-${nomad_region}-*"
{
  capabilities = ["create", "read", "delete", "update"]
}

path "consul-${datacenter}/roles/nomad-deployment-job-${nomad_region}-*"
{
  capabilities = ["create", "read", "delete", "update"]
}

# Nomad server policies for consul agent
path "sys/policies/acl/consul-client-${datacenter}-nomad-server-${nomad_region}-consul-template-*"
{
  capabilities = ["update", "read", "create", "delete"]
}

%{for nomad_dc in var.nomad_regions[nomad_region]}
path "consul-${datacenter}/roles/nomad-${nomad_region}-${nomad_dc}-client-*"
{
  capabilities = ["create", "read", "delete", "update"]
}

# Nomad client policies for consul agent
path "sys/policies/acl/consul-client-${datacenter}-nomad-client-${nomad_region}-${nomad_dc}-consul-template-*"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Create JWT for nomad
path "sys/auth/jwt_nomad_${nomad_region}_${nomad_dc}"
{
  capabilities = ["create", "update", "delete", "read", "sudo"]
}
path "auth/jwt_nomad_${nomad_region}_${nomad_dc}/config"
{
  capabilities = ["read", "update"]
}
path "sys/mounts/auth/jwt_nomad_${nomad_region}_${nomad_dc}"
{
  capabilities = ["read"]
}
path "sys/mounts/auth/jwt_nomad_${nomad_region}_${nomad_dc}/tune"
{
  capabilities = ["read", "update"]
}

%{endfor}

%{endfor}

# Create approle backend
path "sys/auth/approle-consul-${datacenter}"
{
  capabilities = ["create", "update", "delete", "read", "sudo"]
}
path "sys/mounts/auth/approle-consul-${datacenter}"
{
  capabilities = ["read"]
}

# Consul connect
## Intermediate CA
path "sys/mounts/pki_int_connect_${datacenter}"
{
  capabilities = ["create", "update", "read"]
}
path "sys/mounts/pki_int_connect_${datacenter}/tune"
{
  capabilities = ["create", "update", "read"]
}
## CA policy
path "sys/policies/acl/consul-connect-ca-${datacenter}"
{
  capabilities = ["create", "update", "read"]
}

# Create static token
path "consul_static/data/${datacenter}/consul_tokens"
{
  capabilities = ["create", "update", "read", "delete"]
}
path "consul_static/metadata/${datacenter}/consul_tokens"
{
  capabilities = ["read", "delete", "update" ]
}
path "consul_static/data/${datacenter}/gossip"
{
  capabilities = ["create", "update", "read", "delete"]
}
path "consul_static/metadata/${datacenter}/gossip"
{
  capabilities = ["read", "delete"]
}
%{endfor}

#########################
# Permissions for Nomad CA
path "sys/mounts/pki_nomad"
{
  capabilities = ["read", "list", "create", "update"]
}
# Generate root CA
path "pki_nomad/root/generate/internal"
{
  capabilities = ["update"]
}

# upload certificate
path "pki_nomad/config/ca"
{
  capabilities = ["update"]
}

# Add roles for root cert
path "pki_nomad/roles/*"
{
  capabilities = ["read", "create", "update"]
}

# Read PKI issues and update config
path "pki_nomad/issues"
{
  capabilities = ["read"]
}
path "pki_nomad/config/issuers"
{
  capabilities = ["update", "read"]
}

# Update certificate URLs
path "pki_nomad/config/urls"
{
  capabilities = ["update", "read"]
}

# Sign intermediate certificates
path "pki_nomad/root/sign-intermediate"
{
  capabilities = ["update"]
}

# Revoke certificates
path "pki_nomad/revoke"
{
  capabilities = ["update"]
}


%{for region in keys(var.nomad_regions)}

path "sys/mounts/pki_int_nomad_${region}"
{
  capabilities = ["read", "list", "create", "update"]
}

# Generate intermediate CAs
path "pki_int_nomad_${region}/issuers/intermediate/generate/internal"
{
  capabilities = ["update"]
}

# Set default issuer for cert
path "pki_int_nomad_${region}/config/issuers"
{
  capabilities = ["update", "read"]
}

# Set self-signed certificate
path "pki_int_nomad_${region}/intermediate/set-signed"
{
  capabilities = ["update"]
}

# Generate child intermediate certs
path "pki_int_nomad_${region}/root/sign-intermediate"
{
  capabilities = ["update"]
}

# Create/view/delete roles
path "pki_int_nomad_${region}/roles/*"
{
  capabilities = ["update", "read", "delete"]
}

path "sys/policies/acl/nomad-server-consul-template-${region}"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Policy for nomad server vault integration
path "sys/policies/acl/nomad-server-${region}"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Create approle backend
path "sys/auth/approle-nomad-${region}"
{
  capabilities = ["create", "update", "delete", "read", "sudo"]
}
path "sys/mounts/auth/approle-nomad-${region}"
{
  capabilities = ["read"]
}

# Allow creation of vault secret engine for nomad
path "sys/mounts/nomad-${region}"
{
  capabilities = [ "read", "list", "create", "update" ]
}
path "sys/mounts/nomad-${region}/tune"
{
  capabilities = [ "read" ]
}
path "nomad-${region}/config/access"
{
  capabilities = [ "create", "update", "read" ]
}
path "nomad-${region}/config/lease"
{
  capabilities = [ "update", "read" ]
}

# Create nomad engine roles for deployments
path "nomad-${region}/role/nomad-deployment-job-${region}-*"
{
  capabilities = ["create", "read", "delete", "update"]
}

%{for nomad_dc in var.nomad_regions[region]}

path "sys/mounts/pki_int_nomad_${region}_${nomad_dc}"
{
  capabilities = ["read", "list", "create", "update"]
}

# Generate intermediate CAs
path "pki_int_nomad_${region}_${nomad_dc}/issuers/generate/intermediate/internal"
{
  capabilities = ["update"]
}

# Set default issuer for cert
path "pki_int_nomad_${region}_${nomad_dc}/config/issuers"
{
  capabilities = ["update", "read"]
}

# Set self-signed certificate
path "pki_int_nomad_${region}_${nomad_dc}/intermediate/set-signed"
{
  capabilities = ["update"]
}

# Create/view/delete roles
path "pki_int_nomad_${region}_${nomad_dc}/roles/*"
{
  capabilities = ["update", "read", "delete"]
}

path "sys/policies/acl/nomad-client-${region}-${nomad_dc}-consul-template"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Policy for default workload identity
path "sys/policies/acl/default-identity-${region}-${nomad_dc}"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Policy for jobs
path "sys/policies/acl/nomad-job-${region}-${nomad_dc}-*"
{
  capabilities = ["update", "read", "create", "delete"]
}
path "sys/policies/acl/nomad-submit-${region}-${nomad_dc}-*"
{
  capabilities = ["update", "read", "create", "delete"]
}
# Policy for job deployment
path "sys/policies/acl/nomad-deployment-${region}-${nomad_dc}-*"
{
  capabilities = ["update", "read", "create", "delete"]
}
# Policy for Terraform auth
path "sys/policies/acl/nomad-terraform-${region}-${nomad_dc}-*"
{
  capabilities = ["update", "read", "create", "delete"]
}


%{endfor}

%{endfor}


EOF
}

resource "vault_approle_auth_backend_role" "terraform" {
  backend        = vault_auth_backend.approle.path
  role_name      = var.terraform_policy_name
  token_policies = [vault_policy.terraform.name]

  token_bound_cidrs      = ["172.16.94.0/24"]
  token_ttl              = 300
  token_max_ttl          = 300
  token_explicit_max_ttl = 300
}

resource "vault_approle_auth_backend_role_secret_id" "terraform" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.terraform.role_name

  # Admin VPN
  cidr_list = ["172.16.94.0/24"]
}
