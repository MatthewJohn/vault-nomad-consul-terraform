provider "aws" {
  region = "us-east-1"

  endpoints {
    sts = "http://s3.dock.local:9000"
    iam = "http://s3.dock.local:9000"
    s3  = "http://s3.dock.local:9000"
  }

  s3_force_path_style    = true
  skip_get_ec2_platforms = true
}