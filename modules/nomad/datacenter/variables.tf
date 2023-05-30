variable "datacenter" {
  description = "Name of nomad datacenter"
  type        = string
}

variable "root_cert" {
  description = "Root certificate object"
  type = object({
    pki_mount_path         = string
    common_name            = string
    organisation           = string
    ou                     = string
    public_key             = string
    issuer                 = string
    domain_name            = string
    subdomain              = string
    pki_connect_mount_path = string
  })
}

variable "region" {
  description = "Nomad region"
  type = object({
    name               = string
    common_name        = string
    role_name          = string
    pki_mount_path     = string
    approle_mount_path = string
  })
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                     = string
    common_name              = string
    consul_engine_mount_path = string
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    token                    = string
    consul_static_mount_path = string
  })
}

variable "nomad_client_ips" {
  description = "List of all client IP addresses"
  type        = list(string)
  default     = []
}
