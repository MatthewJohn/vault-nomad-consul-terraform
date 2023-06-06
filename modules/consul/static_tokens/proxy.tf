
# https://developer.hashicorp.com/consul/docs/connect/config-entries/proxy-defaults
resource "consul_config_entry" "global_proxy" {
  name = "global"
  kind = "proxy-defaults"

  config_json = jsonencode({
    Mode = "transparent"
    MeshGateway = {
      # @TODO Investigate deploying mesh gateways
      Mode = "none"
    }
    TransparentProxy = {
      OutboundListenerPort = 443  # @TODO Verify
      DialedDirectly       = false  # @TODO Verify
    }
    Expose = {
      Checks = true
    }
  })
}
