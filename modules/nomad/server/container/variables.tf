variable "hostname" {
  description = "Hostname for noamd"
  type        = string
}

variable "image" {
  description = "Image to be used"
  type        = string
}

variable "datacenter" {
  description = "Nomad datacenter"
  type = object({
    name               = string
    common_name        = string
    role_name          = string
    pki_mount_path     = string
    approle_mount_path = string
  })
}

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    consul_static_mount_path = string
    token                    = string
  })
}

variable "consul_template_vault_agent" {
  description = "Vault agent instance for consul template"
  type = object({
    container_id    = string
    token_directory = string
    token_path      = string
  })
}

variable "initial_run" {
  description = "Whether an init is alled"
  type        = bool
  default     = false
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
