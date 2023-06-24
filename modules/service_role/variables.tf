variable "name" {
  description = "Service name"
  type        = string
}

variable "additional_consul_policy" {
  description = "Additional statements for consul policy"
  type        = string
  default     = ""
}

variable "additional_vault_application_policy" {
  description = "Additional statements for vault application policy"
  type        = string
  default     = ""
}

variable "additional_vault_deployment_policy" {
  description = "Additional statements for vault deployment policy"
  type        = string
  default     = ""
}

variable "additional_consul_services" {
  description = "List of additional consul services to assign to service"
  type        = list(string)
  default     = []
}

variable "nomad_datacenter" {
  description = "Nomad datacenter"
  type = object({
    name = string
    common_name = string
    client_dns = string
  })
}

variable "nomad_region" {
  description = "Nomad region"
  type = object({
    name                 = string
    address              = string
    root_cert_public_key = string
    approle_mount_path   = string
  })
}

variable "nomad_bootstrap" {
  description = "Nomad bootstrap object"
  type = object({
    token = string
  })
}

variable "nomad_static_tokens" {
  description = "Nomad static tokens object"
  type = object({
    nomad_engine_mount_path = string
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file               = string
    ca_cert                    = string
    address                    = string
    consul_static_mount_path   = string
    token                      = string
    service_secrets_mount_path = string
  })
}

variable "consul_root_cert" {
  description = "Consul root certificate authority"
  type = object({
    pki_mount_path = string
    public_key     = string
    domain_name    = string
  })
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                     = string
    address                  = string
    address_wo_protocol      = string
    consul_engine_mount_path = string
    root_cert_public_key     = string
  })
}

variable "consul_bootstrap" {
  description = "Value of consul bootstrap"
  type = object({
    token = string
  })
}
