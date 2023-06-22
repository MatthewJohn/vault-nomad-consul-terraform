
variable "service_role" {
  description = "Pre-configured service role to deploy to"
  type = object({
    consul_service_name                = string
    consul_policy_name                 = string
    vault_consul_role_name             = string
    vault_consul_engine_path           = string
    vault_approle_deployment_role_id   = string
    vault_approle_deployment_secret_id = string
    vault_approle_deployment_path      = string
    vault_approle_deployment_login_path = string
    vault_secret_base_path             = string
    vault_secret_base_data_path        = string
    vault_deploy_policy                = string
    vault_application_policy           = string
    vault = object({
      ca_cert = string
      address = string
    })
    consul = object({
      datacenter_name      = string
      address              = string
      address_wo_protocol  = string
      root_cert_public_key = string
    })
    nomad = object({
      address              = string
      root_cert_public_key = string
      region               = string
      datacenter           = string
    })
  })
}

variable "traefik" {
  description = "Traefik instance"
  type = object({
    service_name = string
  })
}

# TO BE REMOVED!!!
variable "nomad_bootstrap" {
  description = "Nomad bootstrap object"
  type = object({
    token = string
  })
}
