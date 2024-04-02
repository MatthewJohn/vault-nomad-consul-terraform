variable "vault_subdomain" {
  description = "Subdomain of primary domain for vault"
  type        = string
  default     = "vault"
}

variable "vault_version" {
  description = "Vault version"
  type        = string
  default     = "1.13.2"
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

variable "kms_key_id" {
  description = "KMS key ID for auto-unseal"
  type        = string
}

variable "kms_backing_key_value" {
  description = "KMS backing key value"
  type        = string
}

variable "all_vault_hosts" {
  description = "List of all vault hostnames"
  type        = list(string)
  default     = []
}

variable "vault_adm_pki_role" {
  description = "Vault adm PKI role"
  type        = string
}

variable "vault_adm_pki_backend" {
  description = "Vault ADM PKI mount"
  type        = string
}

variable "http_proxy" {
  description = "HTTP proxy"
  type        = string
}
