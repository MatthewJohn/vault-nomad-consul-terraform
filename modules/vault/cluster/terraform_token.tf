module "terraform_token" {
  source = "../policy_token"

  policy_name = var.terraform_policy_name

  root_token = var.root_token

  vault_cluster = {
    ca_cert_file = var.ca_cert_file
    address      = local.cluster_address
  }

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

# Update certificate URLs
path "pki_consul/config/urls"
{
  capabilities = ["update", "read"]
}

# Generate intermediate CA
path "pki_consul_int/root/generate/internal"
{
  capabilities = ["update"]
}

EOF
}
