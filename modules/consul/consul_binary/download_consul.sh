#!/bin/bash

set -e

zip_file="consul_${CONSUL_VERSION}_linux_amd64.zip"

if [ ! -f "consul-${CONSUL_VERSION}" ]
then
    wget http://vault.dock.studios/hashicorp/${zip_file}
    unzip ${zip_file}
    rm -f ${zip_file}
    chmod +x ./consul
    mv ./consul ./consul-${CONSUL_VERSION}
fi
