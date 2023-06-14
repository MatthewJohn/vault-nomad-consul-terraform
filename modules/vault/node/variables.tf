
variable "hostname" {
  description = "Hostname for docker"
  type        = string
}

variable "domain_name" {
  description = "DNS domain name for instances"
  type        = string
}

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
