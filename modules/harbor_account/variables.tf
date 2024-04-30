variable "name" {
  description = "Name of robot account"
  type        = string
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    consul_static_mount_path = string
  })
}

variable "harbor_projects" {
  description = "List of required harbor project access"
  type        = list(string)
}

variable "harbor_hostname" {
  description = "Harbor hostname"
  type        = string
}
