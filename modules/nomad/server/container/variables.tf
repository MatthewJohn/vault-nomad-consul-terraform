variable "hostname" {
  description = "Hostname for consul"
  type        = string
}

variable "image" {
  description = "Image to be used"
  type        = string
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                         = string
    common_name                  = string
    role_name                    = string
    pki_mount_path               = string
    agent_consul_template_policy = string
    static_mount_path            = string
    consul_engine_mount_path     = string
    approle_mount_path           = string
    pki_connect_mount_path       = string
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

variable "consul_root_cert" {
  description = "Root certificate object"
  type = object({
    pki_mount_path         = string
    common_name            = string
    organisation           = string
    ou                     = string
    pki_connect_mount_path = string
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
