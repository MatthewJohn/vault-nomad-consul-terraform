variable "http_proxy" {
  description = "HTTP proxy server for build"
  type        = string
  default     = ""
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