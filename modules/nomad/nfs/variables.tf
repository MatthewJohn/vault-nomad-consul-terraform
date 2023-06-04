
variable "nfs_server" {
  description = "FQDN of NFS server"
  type        = string
}

variable "nfs_directory" {
  description = "Data directory to use for NFS"
  type        = string
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
