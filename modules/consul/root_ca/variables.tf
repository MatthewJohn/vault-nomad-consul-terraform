
variable "common_name" {
  description = "Common name for root cert"
  type        = string
  default     = "Dockstudios Consul"
}

variable "domain" {
  description = "Root domain"
  type        = string
}

variable "additional_domains" {
  description = "List of additional root domains for vault"
  type        = list(string)
  default     = []
}

variable "expiry_days" {
  description = "Expiration in days (default 50 years)"
  type        = number
  default     = 18250
}

variable "initial_run" {
  description = "Whether to allow creation of root CA"
  type        = bool
  default     = false
}

variable "consul_binary" {
  description = "Consul binary path"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name for consul CA certificate"
  type        = string
}

variable "bucket_prefix" {
  description = "Bucket key prefix for consul CA certificate"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "aws_region" {
  description = "AWS profile"
  type        = string
}

variable "aws_endpoint" {
  description = "AWS s3 endpoint"
  type        = string
}
