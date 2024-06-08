variable "http_proxy" {
  description = "HTTP proxy server for build"
  type        = string
  default     = ""
}

variable "vault_version" {
  description = "Version of vault"
  type        = string
}

variable "remote_image_name" {
  description = "Remote image name for pushing"
  type        = string
  default     = null
}

variable "remote_image_build_number" {
  description = "Remote image build number"
  type        = string
  default     = null
}