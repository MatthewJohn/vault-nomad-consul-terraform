variable "hostname" {
  description = "Hostname of s3 host"
  type        = string
}

variable "domain_name" {
  description = "Domain name to attach DNS record to"
  type        = string
}

variable "data_directory" {
  description = "Base data directory to use for NFS"
  type        = string
}

variable "exports" {
  description = "Export configuration"
  type        = list(object({
    directory = string
    clients   = list(string)
    options   = optional(string, "rw,no_subtree_check,no_root_squash,insecure,sync")
  }))
}

variable "nomad_datacenter" {
  description = "Nomad datacenter"
  type = object({
    name        = string
    common_name = string
    client_dns  = string
  })
}

variable "nomad_region" {
  description = "Nomad region"
  type = object({
    name                 = string
    address              = string
    root_cert_public_key = string
  })
}

variable "nomad_bootstrap" {
  description = "Nomad bootstrap object"
  type = object({
    token = string
  })
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
