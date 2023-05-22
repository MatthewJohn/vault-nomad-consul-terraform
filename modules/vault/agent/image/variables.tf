variable "http_proxy" {
  description = "HTTP proxy server for build"
  type        = string
  default     = ""
}

variable "vault_version" {
  description = "Version of vault"
  type        = string
}

variable "image_name" {
  description = "Name of image to create"
  type        = string
  default     = "vault-agent"
}
