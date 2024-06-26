
variable "container_name" {
  description = "Custom name for container"
  type        = string
  default     = "vault-agent"
}

variable "domain_name" {
  description = "Container domain name"
  type        = string
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    consul_static_mount_path = string
  })
}

variable "base_directory" {
  description = "Base directory for agent"
  type        = string
  default     = "/vault-agent"
}

variable "app_role_id" {
  description = "App role ID for authentication"
  type        = string
}

variable "app_role_secret" {
  description = "App role secret for authentication"
  type        = string
}

variable "app_role_mount_path" {
  description = "Mount path for approle backend"
  type        = string
}

variable "docker_host" {
  description = "Docker host"
  type = object({
    hostname     = string
    username     = string
    ip           = string
    fqdn         = string
    domain       = string
    bastion_host = optional(string, null)
    bastion_user = optional(string, null)
  })
}

variable "docker_images" {
  description = "Docker images"
  type = object({
    vault_agent_image = string
  })
}