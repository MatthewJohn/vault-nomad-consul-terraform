variable "docker_username" {
  description = "SSH username to connect to docker host"
  type        = string
}

variable "docker_host" {
  description = "Docker host to connect to"
  type        = string
}

variable "docker_ip" {
  description = "IP Address of docker host"
  type        = string
}

variable "hostname" {
  description = "Hostname for docker"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "image" {
  description = "Image to be used"
  type        = string
}

variable "initial_setup" {
  description = "Whether the node is currently being used as initial setup"
  type        = bool
}

variable "all_vault_hosts" {
  description = "List of all vault hostnames"
  type        = list(string)
  default     = []
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

locals {
  vault_domain = "${var.vault_subdomain}.${var.domain_name}"
}
