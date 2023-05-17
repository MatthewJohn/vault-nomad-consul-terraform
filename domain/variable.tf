variable "name" {
  description = "Hostame of domain"
  type        = string
}

variable "domain_name" {
  description = "Domain name of instance"
  type        = string
}

variable "ip_address" {
  description = "IP Address of domain"
  type        = string
}

variable "ip_gateway" {
  description = "IP gateway"
  type        = string
}

variable "nameservers" {
  description = "List of DNS servers for the VM to use"
  type        = list(string)
}

variable "memory" {
  description = "Amount of memory to assign to domain in MiB"
  type        = number
  default     = 1024
}

variable "vcpu_count" {
  description = "Number of vCPUs to assign to domain"
  type        = number
  default     = 1
}

variable "disk_size" {
  description = "Size of disk in MB"
  type        = number
  default     = 8000
}

variable "base_disk_path" {
  description = "Base directory for storing disks"
  default     = null
  type        = string
}

variable "image_name" {
  description = "Source disk image for VM"
  type        = string
  default     = "debian-11-generic-amd64.qcow2"
}

variable "image_source_url" {
  description = "Source disk image URL"
  type        = string
  default     = "https://gemmei.ftp.acc.umu.se/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2"
}

variable "hypervisor_hostname" {
  description = "Hostname for hypervisor"
  type        = string
}

variable "hypervisor_username" {
  description = "Username for hypervisor"
  type        = string
}

variable "base_image_path" {
  description = "Base directory for storing template images"
  default     = null
  type        = string
}

variable "docker_ssh_key" {
  description = "SSH key to connect to docker user"
  type        = string
}

locals {
  base_disk_path       = var.base_disk_path == null ? "/dev/ssd-1" : var.base_disk_path
  disk_is_block_device = var.base_disk_path == null ? true : false

  disk_name = "${var.name}-disk-1"

  base_image_path = var.base_image_path == null ? "/iso" : var.base_image_path
}