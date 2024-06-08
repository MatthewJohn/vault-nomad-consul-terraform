variable "root_cert" {
  description = "Root certificate object"
  type = object({
    public_key = string
  })
}

variable "region" {
  description = "Nomad region"
  type = object({
    name    = string
    address = string
  })
}

variable "bootstrap" {
  description = "Nomad bootstrap object"
  type = object({
    token = string
  })
}
