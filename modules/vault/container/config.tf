locals {

  config_value = <<EOF
disable_mlock = true
ui            = true

storage "file" {
  path = "/vault/file"
}

listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_cert_file = "/vault/ssl/server-fullchain.pem"
  tls_key_file  = "/vault/ssl/server-privkey.pem"
}

EOF
}
