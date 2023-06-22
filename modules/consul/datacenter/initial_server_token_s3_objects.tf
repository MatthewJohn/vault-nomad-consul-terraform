resource "aws_s3_object" "consul_server_token" {
  bucket  = var.bucket_name
  key     = "${var.datacenter}/consul-server-token.txt"
  content = ""

  # Force text/plain content type to force terraform to read the content
  content_type = "text/plain"

  lifecycle {
    ignore_changes = [content]
  }
}

resource "aws_s3_object" "consul_server_service_token" {
  bucket  = var.bucket_name
  key     = "${var.datacenter}/consul-server-service-token.txt"
  content = ""

  # Force text/plain content type to force terraform to read the content
  content_type = "text/plain"

  lifecycle {
    ignore_changes = [content]
  }
}
