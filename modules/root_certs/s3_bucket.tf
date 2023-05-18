
resource "minio_s3_bucket" "root_ca_certificates" {
  bucket = "root_ca_certificates"
  acl = "public-read"
}
