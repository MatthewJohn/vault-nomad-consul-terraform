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

