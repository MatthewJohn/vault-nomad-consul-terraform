variable "http_proxy" {
  description = "HTTP proxy server for build"
  type        = string
}

variable "nomad_version" {
  description = "Version of Nomad"
  type        = string
}

variable "consul_version" {
  description = "Version of Nomad"
  type        = string
}

variable "vault_version" {
  description = "Version of Vault"
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