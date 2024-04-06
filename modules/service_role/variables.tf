variable "nomad_namespace" {
  description = "Nomad namespace for the service to be deployed to"
  type        = string
  default     = "default"
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
