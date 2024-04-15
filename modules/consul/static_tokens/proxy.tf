
# https://developer.hashicorp.com/consul/docs/connect/config-entries/proxy-defaults
resource "consul_config_entry" "global_proxy" {
  name = "global"
  kind = "proxy-defaults"

  config_json = jsonencode({
    Mode             = "direct"
    AccessLogs       = {}
    Expose           = {}
    MeshGateway      = {}
    TransparentProxy = {}
  })
}
