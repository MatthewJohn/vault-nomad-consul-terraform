variable "base_disk_path" {
  description = "Base directory for storing disks"
  default     = null
  type        = string
}

variable "base_image_path" {
  description = "Base directory for storing template images"
  default     = null
  type        = string
}

variable "hypervisor_hostname" {
  description = "Hostname for hypervisor"
  type        = string
}

variable "hypervisor_username" {
  description = "Username for hypervisor"
  type        = string
}

variable "nameservers" {
  description = "List of DNS servers for the VMs to use"
  type        = list(string)
}

variable "docker_ssh_key" {
  description = "SSH key to connect to docker user"
  type        = string
}

variable "domain_name" {
  description = "DNS domain name for instances"
  type        = string
}

variable "hosts_entries" {
  description = "Additional hosts entries for VMs"
  type        = map(list(string))
  default     = {}
}

variable "vault_hosts" {
  type = map(object({
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = list(string)
    memory                   = optional(number, 386)
    disk_size                = optional(number, 3000)
  }))
}

variable "consul_hosts" {
  description = "List of nomad clients"
  type = map(object({
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = list(string)
    memory                   = optional(number, 386)
    disk_size                = optional(number, 4000)
  }))
}

variable "nomad_server_hosts" {
  description = "List of nomad server host configurations"
  type = map(object({
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = optional(list(string), [])
    memory                   = optional(number, 512)
    disk_size                = optional(number, 5000)
  }))
  default = {}
}

variable "nomad_client_hosts" {
  description = "List of nomad client host configurations"
  type = map(object({
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = optional(list(string), [])
    memory                   = optional(number, 1537)
    disk_size                = optional(number, 6500)
  }))
  default = {}
}

variable "storage_server" {
  description = "Configuration of shared NFS storage server"
  type = object({
    name                     = string
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = optional(list(string), [])
    directories              = list(string)
    disk_size                = optional(number, 2500)
  })
  default = null
}

variable "monitoring_server" {
  description = "Configuration of monitoring server"
  type = object({
    name                     = string
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = optional(list(string), [])
    disk_size                = optional(number, 3500)
  })
  default = null
}
