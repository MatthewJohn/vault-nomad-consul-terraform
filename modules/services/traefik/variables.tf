variable "nomad_datacenter" {
  description = "Nomad datacenter"
  type = object({
    name = string
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



