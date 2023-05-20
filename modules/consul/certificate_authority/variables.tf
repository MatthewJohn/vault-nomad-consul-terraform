
variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "consul_subdomain" {
  description = "Consul subdomain of domain name for CA"
  type        = string
  default     = "consul"
}

variable "ou" {
  description = "OU for root certificate"
  type        = string
  default     = "Consul"
}

variable "organisation" {
  description = "Organisation for root certificate"
  type        = string
  default     = "Dockstudios"
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file = string
    address      = string
    token        = string
  })
}

locals {
  common_name = "${var.consul_subdomain}.${var.domain_name}"
}
