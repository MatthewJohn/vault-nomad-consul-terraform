variable "name" {
  description = "Service name"
  type        = string
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
