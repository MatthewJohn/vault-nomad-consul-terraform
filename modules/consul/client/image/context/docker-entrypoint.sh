#!/usr/bin/dumb-init /bin/sh
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

set -e

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.
# As of docker 1.13, using docker run --init achieves the same outcome.

# You can set CONSUL_BIND_INTERFACE to the name of the interface you'd like to
# bind to and this will look up the IP and pass the proper -bind= option along
# to Consul.
CONSUL_BIND=
if [ -n "$CONSUL_BIND_INTERFACE" ]; then
  CONSUL_BIND_ADDRESS=$(ip -o -4 addr list $CONSUL_BIND_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_BIND_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_BIND_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_BIND="-bind=$CONSUL_BIND_ADDRESS"
  echo "==> Found address '$CONSUL_BIND_ADDRESS' for interface '$CONSUL_BIND_INTERFACE', setting bind option..."
fi

# You can set CONSUL_CLIENT_INTERFACE to the name of the interface you'd like to
# bind client intefaces (HTTP, DNS, and RPC) to and this will look up the IP and
# pass the proper -client= option along to Consul.
CONSUL_CLIENT=
if [ -n "$CONSUL_CLIENT_INTERFACE" ]; then
  CONSUL_CLIENT_ADDRESS=$(ip -o -4 addr list $CONSUL_CLIENT_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
  if [ -z "$CONSUL_CLIENT_ADDRESS" ]; then
    echo "Could not find IP for interface '$CONSUL_CLIENT_INTERFACE', exiting"
    exit 1
  fi

  CONSUL_CLIENT="-client=$CONSUL_CLIENT_ADDRESS"
  echo "==> Found address '$CONSUL_CLIENT_ADDRESS' for interface '$CONSUL_CLIENT_INTERFACE', setting client option..."
fi

# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage. The
# CONSUL_CONFIG_DIR isn't exposed as a volume but you can compose additional
# config files in there if you use this image as a base, or use CONSUL_LOCAL_CONFIG
# below.
CONSUL_DATA_DIR=/consul/data
CONSUL_CONFIG_DIR=/consul/config


# If the user is trying to run Consul directly with some arguments, then
# pass them to Consul.
if [ "${1:0:1}" = '-' ]; then
    set -- consul "$@"
fi

# Set file permissions
if [ "$1" = 'consul' ]; then
    if [ -z "$SKIP_CHOWN" ]; then
        chown -R :consul /consul/config
        chmod 775 /consul/config
        chmod 644 /consul/config/*
        chown -R :consul /consul/config/templates
        chmod 755 /consul/config/templates
        chmod 644 /consul/config/templates/*

        chown -R consul: /consul/config/client-certs
        chmod 755 /consul/config/client-certs
        if ls /consul/config/client-certs/*
        then
          chmod 644 /consul/config/templates/*
        fi

        touch /consul/config/consul.hcl
        chown consul: /consul/config/consul.hcl

        chown -R consul: /consul/data
        chmod 755 /consul/data
    fi
fi

# Look for Consul subcommands.
if [ "$1" = 'agent' ]; then
    shift
    set -- consul agent \
        -data-dir="$CONSUL_DATA_DIR" \
        -config-dir="$CONSUL_CONFIG_DIR" \
        $CONSUL_BIND \
        $CONSUL_CLIENT \
        "$@"
elif [ "$1" = 'version' ]; then
    # This needs a special case because there's no help output.
    set -- consul "$@"
elif consul --help "$1" 2>&1 | grep -q "consul $1"; then
    # We can't use the return code to check for the existence of a subcommand, so
    # we have to use grep to look for a pattern in the help output.
    set -- consul "$@"
fi

# NOTE: Unlike in the regular Consul Docker image, we don't have code here
# for changing data-dir directory ownership or using su-exec because OpenShift
# won't run this container as root and so we can't change data dir ownership,
# and there's no need to use su-exec.

if [[ "$(id -u)" == '0' ]]
then
    export SKIP_CHOWN="true"
    export SKIP_SETCAP="true"

    # Allow consul to listen on all ports
    setcap CAP_NET_BIND_SERVICE=+eip /bin/consul

    exec su consul -p "$0" -- "$@"
else
    cat > /tmp/start_consul.sh <<EOF
#!/bin/bash

exec $@
EOF
    chmod +x /tmp/start_consul.sh

    # run consul-template in the backgroundn to update certs
    # @TODO Get consul-template to trigger consul reload
    consul-template \
      -config /consul/config/templates/consul_template.hcl \
      -exec-kill-timeout=30s \
      -exec /tmp/start_consul.sh
fi
