module "terraform_token" {
  source = "../policy_token"

  policy_name = var.terraform_policy_name

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
path "sys/mounts/pki_consul"
{
  capabilities = ["read", "list", "create"]
}
# Revoke certificates
path "pki_consul/revoke"
{
  capabilities = ["update"]
}
# Generate root CA
path "pki_consul/root/generate/internal"
{
  capabilities = ["update"]
}

# upload certificate
path "pki_consul/config/ca"
{
  capabilities = ["update"]
}

# Add roles for root cert
path "pki_consul/roles/*"
{
  capabilities = ["read", "create", "update"]
}

# Read PKI issues and update config
path "pki_consul/issues"
{
  capabilities = ["read"]
}
path "pki_consul/config/issuers"
{
  capabilities = ["update", "read"]
}

# Update certificate URLs
path "pki_consul/config/urls"
{
  capabilities = ["update", "read"]
}

# Sign intermediate certificates
path "pki_consul/root/sign-intermediate"
{
  capabilities = ["update"]
}

# Consul connect
## CA
path "sys/mounts/pki_connect"
{
  capabilities = ["create", "update", "read"]
}

%{for datacenter in var.consul_datacenters}
path "sys/mounts/pki_int_consul_${datacenter}"
{
  capabilities = ["read", "list", "create", "update"]
}

# Generate intermediate CAs
path "pki_int_consul_${datacenter}/intermediate/generate/internal"
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

%{for nomad_dc in var.nomad_regions[nomad_region]}
path "consul-${datacenter}/roles/nomad-${nomad_region}-${nomad_dc}-client-*"
{
  capabilities = ["create", "read", "delete", "update"]
}
%{endfor}

%{endfor}

# Create approle backend
path "sys/auth/approle-consul-${datacenter}"
{
  capabilities = ["create", "update", "delete", "read", "sudo"]
}

# Consul connect
## Intermediate CA
path "sys/mounts/pki_int_connect_${datacenter}"
{
  capabilities = ["create", "update", "read"]
}
## CA policy
path "sys/policies/acl/consul-connect-ca-${datacenter}"
{
  capabilities = ["create", "update", "read"]
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
path "pki_int_nomad_${region}/intermediate/generate/internal"
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

# Policy for jobs
path "sys/policies/acl/nomad-job-${region}-*"
{
  capabilities = ["update", "read", "create", "delete"]
}
# Policy for job deployment
path "sys/policies/acl/nomad-deployment-job-${region}-*"
{
  capabilities = ["update", "read", "create", "delete"]
}

# Assume roles for deploy nomad jobs
path "auth/token/create/nomad-job-${region}-*"
{
  capabilities = [ "sudo" ]
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
path "pki_int_nomad_${region}_${nomad_dc}/intermediate/generate/internal"
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


%{endfor}

%{endfor}


EOF
}
