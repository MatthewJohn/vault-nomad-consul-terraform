
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

variable "vault_adm_pki_role" {
  description = "Vault adm PKI role"
  type        = string
}

variable "vault_adm_pki_backend" {
  description = "Vault ADM PKI mount"
  type        = string
}

variable "docker_host" {
  description = "Docker host"
  type = object({
    hostname     = string
    username     = string
    ip           = string
    fqdn         = string
    domain       = string
    bastion_host = optional(string, null)
    bastion_user = optional(string, null)
  })
}

locals {
  vault_domain = "${var.vault_subdomain}.${var.docker_host.domain}"
}
