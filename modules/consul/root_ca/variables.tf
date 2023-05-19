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
