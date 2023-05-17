locals {
  vault_config = <<EOF
{
    "storage": {
        "file": {
            "path": "/vault/file"
        }
    },
    "listener": [
        {"tcp": { "address": "0.0.0.0:8200", "tls_disable": true}}
    ],
    "default_lease_ttl": "168h",
    "max_lease_ttl": "720h",
    "ui": true
}
EOF

  vault_config_stripped = replace(local.vault_config, "\n", "")
}