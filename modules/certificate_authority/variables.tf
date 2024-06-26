
variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "subdomain" {
  description = "Subdomain of domain name for CA"
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
    address        = string
    pki_mount_path = string
  })
}

variable "root_ca_cert" {
  description = "Root CA public key"
  type        = string
}

variable "allow_wildcard_certificates" {
  description = "Whether role should allow wildcards"
  type        = bool
  default     = null
}

variable "create_connect_ca" {
  description = "Whether to create additional Consul connect CA"
  type        = bool
  default     = false
}

variable "mount_name" {
  description = "Vault mount name for CA"
  type        = string
}

variable "description" {
  description = "Description of Mount for CA"
  type        = string
}

locals {
  common_name = "${var.subdomain}.${var.domain_name}"
}
