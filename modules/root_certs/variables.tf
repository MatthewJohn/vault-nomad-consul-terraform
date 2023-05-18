variable "root_cn" {
  description = "Domain used for root CA"
  type        = string
}

variable "organisation" {
  description = "Organisation for certificates"
  type        = string
  default     = "DockStudios Ltd"
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

