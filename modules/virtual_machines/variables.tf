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

variable "vault_version" {
  description = "Vault version"
  type = string
  default = "1.13.2"
}
