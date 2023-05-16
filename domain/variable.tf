variable "name" {
  description = "Hostame of domain"
  type        = string
}

variable "ip_address" {
  description = "IP Address of domain"
  type        = string
}

variable "memory" {
  description = "Amount of memory to assign to domain in MiB"
  type        = number
}

variable "vcpu_count" {
  description = "Number of vCPUs to assign to domain"
  type        = number
  default     = 1
}