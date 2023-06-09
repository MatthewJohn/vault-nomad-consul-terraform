# Comment on first run
terraform {
  backend "s3" {
    bucket   = "admin-terraform-state"
    endpoint = "http://s3.dock.local:9000"
    key      = "vault-nomad-consul/root-certs/terraform.tfstate"
    profile  = "dockstudios-admin-terraform"

    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
