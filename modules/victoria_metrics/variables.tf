
variable "hostname" {
  description = "Hostname"
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

variable "vault_cluster" {
  description = "Vault cluster config"
  type = object({
    ca_cert_file             = string
    address                  = string
    consul_static_mount_path = string
    token                    = string
    approle_mount_path       = string
  })
}

variable "consul_datacenter" {
  description = "Consul datacenter"
  type = object({
    name                                     = string
    common_name                              = string
    client_ca_role_name                      = string
    pki_mount_path                           = string
    client_consul_template_approle_role_name = string
    static_mount_path                        = string
    consul_engine_mount_path                 = string
    approle_mount_path                       = string
    pki_connect_mount_path                   = string
    ca_chain                                 = string
    root_cert_public_key                     = string
    address                                  = string
  })
}

variable "consul_root_cert" {
  description = "Consul root certificate authority"
  type = object({
    pki_mount_path         = string
    common_name            = string
    organisation           = string
    ou                     = string
    pki_connect_mount_path = string
    public_key             = string
  })
}

variable "consul_bootstrap" {
  description = "Value of consul bootstrap"
  type = object({
    token = string
  })
}

variable "consul_version" {
  description = "Version of consul"
  type        = string
}
