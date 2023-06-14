provider "aws" {
  region = "us-east-1"

  endpoints {
    sts = "http://s3.dock.local:9000"
    iam = "http://s3.dock.local:9000"
    s3  = "http://s3.dock.local:9000"
  }

  profile = "dockstudios-admin-terraform"

  s3_force_path_style         = true
  skip_requesting_account_id  = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
}

terraform {
  required_providers {
    aws = {
      version = "3.76.1"
    }
  }
}
