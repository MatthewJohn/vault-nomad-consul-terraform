variable "hostname" {
  description = "Server hostname"
  type        = string
}

variable "vault_domain" {
  description = "Vault domain"
  type        = string
}

variable "ip_address" {
  description = "IP Address of host"
  type        = string
}

variable "key_algorithm" {
  description = "Key algorithm used for certificates"
  type        = string
  default     = "ECDSA"
}

variable "ecdsa_curve" {
  description = "ECDSA Curve"
  type        = string
  default     = "P384"
}

variable "vault_adm_pki_role" {
  description = "Vault adm PKI role"
  type        = string
}

variable "vault_adm_pki_backend" {
  description = "Vault ADM PKI mount"
  type        = string
}