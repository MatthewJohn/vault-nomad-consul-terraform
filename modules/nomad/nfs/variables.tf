
variable "nfs_server" {
  description = "FQDN of NFS server"
  type        = string
}

variable "nfs_directory" {
  description = "Data directory to use for NFS"
  type        = string
}

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

locals {
  plugin_id = "nfs-${var.service_role.nomad.region}-${var.service_role.nomad.datacenter}"
}
