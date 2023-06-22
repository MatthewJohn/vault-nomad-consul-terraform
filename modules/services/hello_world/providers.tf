# Create file for vault CA cert
resource "random_string" "vault_ca_cert" {
  length           = 16
  special          = false
}
resource "local_file" "vault_ca_cert" {
  content = var.service_role.vault.ca_cert
  filename = "${path.module}/vault-ca-${random_string.vault_ca_cert.result}.crt"
}

# Use vault provider with approle authentication
provider "vault" {
  address      = var.service_role.vault.address
  ca_cert_file = local_file.vault_ca_cert.filename

  auth_login {
    path = var.service_role.vault_approle_deployment_path

    parameters = {
      role_id   = var.service_role.vault_approle_deployment_role_id
      secret_id = var.service_role.vault_approle_deployment_secret_id
    }
  }
}

# Re-login to obtain vault token used in nomad job
resource "vault_approle_auth_backend_login" "login" {
  backend   = var.service_role.vault_approle_deployment_path
  role_id   = var.service_role.vault_approle_deployment_role_id
  secret_id = var.service_role.vault_approle_deployment_secret_id
}

# Obtain nomad token from vault consul engine
data "vault_generic_secret" "consul_token" {
  path = "${var.service_role.vault_consul_engine_path}/creds/${var.service_role.vault_consul_role_name}"
}

# Login to consul using token from consul engine from vault
provider "consul" {
  address    = var.service_role.consul.address
  datacenter = var.service_role.consul.datacenter
  # @TODO Replace with more restrictive terraform token
  token  = data.vault_generic_secret.consul_token.data_json["Token"]
  ca_pem = var.service_role.consul.root_cert_public_key
}

provider "nomad" {
  address   = var.service_role.nomad.address
  region    = var.service_role.nomad.region
  secret_id = var.nomad_bootstrap.token
  ca_pem    = var.service_role.nomad.root_cert_public_key
}
