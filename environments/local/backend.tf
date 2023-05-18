# Comment on first run
terraform {
  backend "s3" {
    bucket   = "terraform-state"
    endpoint = "http://s3.dock.local:9000"
    key      = "vault-nomad-consul/terraform.tfstate"
    profile  = "dockstudios-terraform"

    region                      = "eu-east-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "aws" {
  region = "us-east-1"

  endpoints {
    sts = "http://s3.dock.local:9000"
    iam = "http://s3.dock.local:9000"
    s3  = "http://s3.dock.local:9000"
  }

  profile = "dockstudios-terraform"

  s3_use_path_style           = true
  skip_requesting_account_id  = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}

