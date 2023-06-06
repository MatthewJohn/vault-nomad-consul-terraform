resource "consul_config_entry" "global_proxy" {
  name = "global"
  kind = "proxy-defaults"

  config_json = jsonencode({
    Mode = "transparent"
  })
}
