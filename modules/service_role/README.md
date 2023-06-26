# Service role

Creates vault, consul and nomad roles for an application deployment

Provides minimal permission set to allow the deployment an application:

Creates:
 * Vault approle for deployment Terraform to authentication
 * Vault deployment policy/role, allowing obtaining nomad/consul tokens and setting application-specific secrets in vault
 * Vault application policy, allowing application to obtain application-specific secrets and consul token
 * Consul policy, allowing writing to application service and keys, and role for application with role in Vault nomad engine to obtain token
 * Nomad policy and role for deployment with role in Vault nomad engine to obtain token

Additional policy snippets can be passed for all policies.

## Passing output into a deployment Terraform code:

Setup variable using output of service_role:
```

variable "service_role" {
  description = "Pre-configured service role to deploy to"
  type = object({
    name                                = string
    consul_service_name                 = string
    consul_policy_name                  = string
    vault_consul_role_name              = string
    vault_consul_engine_path            = string
    vault_nomad_role_name               = string
    vault_nomad_engine_path             = string
    vault_approle_deployment_role_id    = string
    vault_approle_deployment_secret_id  = string
    vault_approle_deployment_path       = string
    vault_approle_deployment_login_path = string
    vault_role_name                     = string
    vault_secret_base_path              = string
    vault_secret_base_data_path         = string
    vault_deploy_policy                 = string
    vault_application_policy            = string
    vault = object({
      ca_cert = string
      address = string
    })
    consul = object({
      datacenter               = string
      address                  = string
      address_wo_protocol      = string
      root_cert_public_key     = string
      root_cert_pki_mount_path = string
    })
    nomad = object({
      address                = string
      root_cert_public_key   = string
      region                 = string
      datacenter             = string
      datacenter_common_name = string
      datacenter_client_dns  = string
      root_domain_name       = string
      namespace              = string
    })
  })
}
```

Create provider configuration:
```
# Create file for vault CA cert.
# Vault provider current needs the vault CA cert as a file on disk,
# unlike the other hashicorp providers, so create temporary file
# using data source (as this needs to be available at plan-time)
data "external" "temp_vault_cert" {
  program = [
    "bash", "-c", <<EOF
temp_cert=$(mktemp)
cat > $temp_cert <<EOC
${var.service_role.vault.ca_cert}
EOC
echo "{\"cert_file\": \"$temp_cert\"}"
EOF
  ]
}

# Use vault provider with approle authentication
provider "vault" {
  address      = var.service_role.vault.address
  ca_cert_file = data.external.temp_vault_cert.result.cert_file
  skip_child_token = true

  auth_login {
    path = var.service_role.vault_approle_deployment_login_path

    parameters = {
      role_id   = var.service_role.vault_approle_deployment_role_id
      secret_id = var.service_role.vault_approle_deployment_secret_id
    }
  }
}

resource "vault_token" "role_token" {
  role_name = var.service_role.vault_role_name

  renewable = true
}

# Obtain nomad token from vault consul engine
data "vault_generic_secret" "consul_token" {
  path = "${var.service_role.vault_consul_engine_path}/creds/${var.service_role.vault_consul_role_name}"
}

# Login to consul using token from consul engine from vault
provider "consul" {
  address    = var.service_role.consul.address
  datacenter = var.service_role.consul.datacenter
  token  = data.vault_generic_secret.consul_token.data["token"]
  ca_pem = var.service_role.consul.root_cert_public_key
}

# Obtain nomad token from vault nomad engine
data "vault_generic_secret" "nomad_token" {
  path = "${var.service_role.vault_nomad_engine_path}/creds/${var.service_role.vault_nomad_role_name}"
}

provider "nomad" {
  address   = var.service_role.nomad.address
  region    = var.service_role.nomad.region
  secret_id = data.vault_generic_secret.nomad_token.data["secret_id"]
  ca_pem    = var.service_role.nomad.root_cert_public_key
}
```
