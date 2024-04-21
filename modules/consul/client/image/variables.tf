variable "http_proxy" {
  description = "HTTP proxy server for build"
  type        = string
  default     = ""
}

variable "consul_version" {
  description = "Version of Consul"
  type        = string
}

variable "vault_version" {
  description = "Version of Vault"
  type        = string
}
