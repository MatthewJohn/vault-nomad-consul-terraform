variable "nomad_datacenter" {
  description = "Nomad datacenter"
  type = object({
    name        = string
    common_name = string
    client_dns  = string
  })
}

variable "nomad_region" {
  description = "Nomad region"
  type = object({
    name                 = string
    address              = string
    root_cert_public_key = string
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
    ca_cert_file             = string
    address                  = string
    consul_static_mount_path = string
    token                    = string
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
