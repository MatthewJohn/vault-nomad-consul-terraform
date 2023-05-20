resource "vault_policy" "admin" {
  name = var.admin_policy_name

  # Copied from https://github.com/hashicorp/learn-vault-codify/blob/main/oss/policies/admin-policy.hcl
  policy = <<EOF
# Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List ACL policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage secrets engines broadly across Vault.
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List enabled secrets engines
path "sys/mounts"
{
  capabilities = ["read", "list"]
}

# List, create, update, and delete key/value secrets at secret/
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage transit secrets engine
path "transit/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage PKI secrets engine
path "pki/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Generate root CA
path "consul/root/generate/internal"
{
  capabilities = ["update"]
}

# Update certificate URLs
path "consul/config/urls"
{
  capabilities = ["update", "read"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
EOF
}