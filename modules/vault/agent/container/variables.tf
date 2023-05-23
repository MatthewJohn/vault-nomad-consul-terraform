
variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    token                    = string
    consul_static_mount_path = string
  })
}

variable "container_name" {
  description = "Custom name for container"
  type        = string
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
  type = string
}

variable "base_directory" {
  description = "Base directory for agent"
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

variable "image" {
  description = "Image to be used"
  type        = string
}
