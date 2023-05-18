variable "hostname" {
  description = "Server hostname"
  type        = string
}

variable "vault_domain" {
  description = "Vault domain"
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
