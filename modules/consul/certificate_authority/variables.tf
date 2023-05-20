
variable "common_name" {
  description = "Common name for root certificate"
  type        = string
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
