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

# Create and manage secrets engines broadly across Vault.
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "list"]
}

# Create token
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

#########################
# Permissions for Consul CA
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

%{for datacenter in var.consul_datacenters}
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

path "sys/policies/acl/consul-cert-${datacenter}"
{
  capabilities = ["update", "read", "create", "delete"]
}

%{endfor}

EOF
}
