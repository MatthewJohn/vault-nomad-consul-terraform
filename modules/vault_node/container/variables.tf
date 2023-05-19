variable "docker_username" {
  description = "SSH username to connect to docker host"
  type        = string
}

variable "docker_host" {
  description = "Docker host to connect to"
  type        = string
}

variable "docker_ip" {
  description = "IP Address of docker host"
  type        = string
}

variable "hostname" {
  description = "Hostname for docker"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "image" {
  description = "Image to be used"
  type        = string
}

variable "all_vault_hosts" {
  description = "List of all vault hostnames"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "KMS key ID for auto-unseal"
  type        = string
}

variable "kms_backing_key_value" {
  description = "KMS backing key value"
  type        = string
}

variable "vault_subdomain" {
  description = "Subdomain of primary domain for vault"
  type        = string
  default     = "vault"

  validation {
    condition     = var.vault_subdomain != "" && var.vault_subdomain != null
    error_message = "The vault_subdomain cannot be empty."
  }
}

locals {
  vault_domain = "${var.vault_subdomain}.${var.domain_name}"
}
