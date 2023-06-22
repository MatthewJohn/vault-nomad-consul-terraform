
variable "datacenter" {
  description = "Datacenter name"
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

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    token                    = string
    consul_static_mount_path = string
  })
}

variable "bucket_name" {
  description = "S3 bucket name for storing server keys"
  type        = string
}

variable "global_config" {
  description = "Global consul config"
  type = object({
    primary_datacenter = string
  })
}

variable "agent_ips" {
  description = "List of all agent IP addresses"
  type        = list(string)
  default     = []
}

locals {
  is_primary_datacenter = var.global_config.primary_datacenter == var.datacenter ? true : false

  consul_engine_mount_path = "consul-${var.datacenter}"
}
