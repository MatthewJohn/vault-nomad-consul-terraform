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

        chown -R nomad: /nomad/config/agent-certs
        chmod 755 /nomad/config/agent-certs
        if ls /nomad/config/agent-certs/*
        then
          chmod 644 /nomad/config/templates/*
        fi

        touch /nomad/config/nomad.hcl
        chown nomad: /nomad/config/nomad.hcl

        chown -R nomad: /nomad/data
        chmod 755 /nomad/data
    fi
fi

if [[ "$(id -u)" == '0' ]]
then
    export SKIP_CHOWN="true"
    export SKIP_SETCAP="true"

    # Allow nomad to listen on all ports
    setcap CAP_NET_BIND_SERVICE=+eip /bin/nomad

    exec su nomad -p "$0" -- "$@"
else
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
