#!/bin/sh
set -e

# Prevent core dumps
ulimit -c 0

# Allow setting VAULT_REDIRECT_ADDR and VAULT_CLUSTER_ADDR using an interface
# name instead of an IP address. The interface name is specified using
# VAULT_REDIRECT_INTERFACE and VAULT_CLUSTER_INTERFACE environment variables. If
# VAULT_*_ADDR is also set, the resulting URI will combine the protocol and port
# number with the IP of the named interface.
get_addr () {
    local if_name=$1
    local uri_template=$2
    ip addr show dev $if_name | awk -v uri=$uri_template '/\s*inet\s/ { \
      ip=gensub(/(.+)\/.+/, "\\1", "g", $2); \
      print gensub(/^(.+:\/\/).+(:.+)$/, "\\1" ip "\\2", "g", uri); \
      exit}'
}

if [ -n "$VAULT_REDIRECT_INTERFACE" ]; then
    export VAULT_REDIRECT_ADDR=$(get_addr $VAULT_REDIRECT_INTERFACE ${VAULT_REDIRECT_ADDR:-"http://0.0.0.0:8200"})
    echo "Using $VAULT_REDIRECT_INTERFACE for VAULT_REDIRECT_ADDR: $VAULT_REDIRECT_ADDR"
fi
if [ -n "$VAULT_CLUSTER_INTERFACE" ]; then
    export VAULT_CLUSTER_ADDR=$(get_addr $VAULT_CLUSTER_INTERFACE ${VAULT_CLUSTER_ADDR:-"https://0.0.0.0:8201"})
    echo "Using $VAULT_CLUSTER_INTERFACE for VAULT_CLUSTER_ADDR: $VAULT_CLUSTER_ADDR"
fi

# If the user is trying to run Vault directly with some arguments, then
# pass them to Vault.
if [ "${1:0:1}" = '-' ]; then
    set -- vault "$@"
fi

# If we are running Vault, make sure it executes as the proper user.
if [ "$1" = 'vault' ]; then
    if [ -z "$SKIP_CHOWN" ]; then
        # If the config dir is bind mounted then chown it
        chown -R root:vault /vault/config || echo "Could not chown /vault/config (may not have appropriate permissions)"
        chmod 755 /vault/config || echo "Could not chmod /vault/config (may not have appropriate permissions)"
        chmod 644 /vault/config/* || echo "Could not chmod /vault/config/* (may not have appropriate permissions)"

        chown -R root:vault /vault/ssl || echo "Could not chown /vault/ssl (may not have appropriate permissions)"
        chmod 755 /vault/ssl || echo "Could not chmod /vault/ssl (may not have appropriate permissions)"
        chmod 644 /vault/ssl/* || echo "Could not chmod /vault/ssl/* (may not have appropriate permissions)"
        

        # If the logs dir is bind mounted then chown it
        if [ "$(stat -c %u /vault/logs)" != "$(id -u vault)" ]; then
            chown -R vault:vault /vault/logs
        fi

        # If the file dir is bind mounted then chown it
        if [ "$(stat -c %u /vault/file)" != "$(id -u vault)" ]; then
            chown -R vault:vault /vault/file
        fi
    fi

    if [ -z "$SKIP_SETCAP" ]; then
        # Allow mlock to avoid swapping Vault memory to disk
        setcap cap_ipc_lock=+ep $(readlink -f /bin/vault)

        # In the case vault has been started in a container without IPC_LOCK privileges
        if ! vault -version 1>/dev/null 2>/dev/null; then
            >&2 echo "Couldn't start vault with IPC_LOCK. Disabling IPC_LOCK, please use --cap-add IPC_LOCK"
            setcap cap_ipc_lock=-ep $(readlink -f /bin/vault)
        fi
    fi
fi

# In case of Docker, where swap may be enabled, we 
# still require mlocking to be available. So this script 
# was executed as root to make this happen, however, 
# we're now rerunning the entrypoint script as the Vault 
# user but no longer need to run setup code for setcap
# or chowning directories (previously done on the first run).
if [[ "$(id -u)" == '0' ]]
then
    export SKIP_CHOWN="true"
    export SKIP_SETCAP="true"
    exec su vault -p "$0" -- "$@"
else
    exec "$@" 
fi