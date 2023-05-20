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
  }))
}

variable "consul_hosts" {
  type = map(object({
    ip_address               = string
    ip_gateway               = string
    network_bridge           = optional(string)
    additional_dns_hostnames = list(string)
  }))
}
