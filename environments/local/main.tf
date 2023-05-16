
locals {
  freeipa_admin = "admin"
  freeipa_password = "password"
}

module "freeipa_initial_setup" {
  source = "./freeipa"

  initial_setup    = true
  freeipa_password = local.freeipa_password
}

module "freeipa" {
  source = "./freeipa"

  freeipa_password = local.freeipa_password
}

module "this" {
  source = "../../"
}


provider "docker" {
  alias = "local"
}


