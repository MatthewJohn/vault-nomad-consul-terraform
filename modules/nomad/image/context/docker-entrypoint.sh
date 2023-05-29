#!/usr/bin/dumb-init /bin/sh

set -e

# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage. The
# CONSUL_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use CONSUL_LOCAL_CONFIG
# below.
CONSUL_DATA_DIR=/nomad/data
CONSUL_CONFIG_DIR=/nomad/config


# If the user is trying to run Consul directly with some arguments, then
# pass them to Consul.
if [ "${1:0:1}" = '-' ]; then
    set -- nomad "$@"
fi

# Set file permissions
if [ "$1" = 'nomad' ]; then
    if [ -z "$SKIP_CHOWN" ]; then
        chown -R :nomad /nomad/config
        chmod 775 /nomad/config
        chmod 644 /nomad/config/*
        chown -R :nomad /nomad/config/templates
        chmod 755 /nomad/config/templates
        chmod 644 /nomad/config/templates/*

        chown -R nomad: /nomad/config/server-certs
        chmod 755 /nomad/config/server-certs
        if ls /nomad/config/server-certs/*
        then
          chmod 644 /nomad/config/server-certs/*
        fi
        chmod 755 /nomad/config/consul-certs

        touch /nomad/config/server.hcl
        chown nomad: /nomad/config/server.hcl

        chown -R nomad: /nomad/data
        chmod 755 /nomad/data

        mkdir -p /sys/fs/cgroup/nomad.slice

        # Enable bridge network routing
        echo 1 > /proc/sys/net/bridge/bridge-nf-call-arptables
        echo 1 > /proc/sys/net/bridge/bridge-nf-call-ip6tables
        echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
    fi
fi

if [[ "$(id -u)" == '0' ]]
then
    export SKIP_CHOWN="true"
    export SKIP_SETCAP="true"

    cat > /tmp/start_nomad.sh <<EOF
#!/bin/bash

$@
EOF
    chmod +x /tmp/start_nomad.sh

    # run nomad-template in the backgroundn to update certs
    # @TODO Get nomad-template to trigger nomad reload
    consul-template \
      -config /nomad/config/templates/consul_template.hcl \
      -exec /tmp/start_nomad.sh
fi
