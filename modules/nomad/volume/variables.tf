variable "name" {
  description = "Volume name"
  type        = string
}

variable "directory" {
  description = "Sub-directory on NFS server DC mount for volume. Defaults to name of volume"
  type        = string
  default     = null
}

variable "nfs" {
  description = "NFS plugin"
  type = object({
    plugin_id = string
  })
}

variable "uid" {
  description = "Owner UID of the volume"
  type        = number
}

variable "gid" {
  description = "Group GID of the volume"
  type        = number
}

variable "mode" {
  description = "Mount permission mode of volume"
  type        = string
  default     = "770"
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

locals {
  external_id = var.directory != null ? var.directory : var.name
}
