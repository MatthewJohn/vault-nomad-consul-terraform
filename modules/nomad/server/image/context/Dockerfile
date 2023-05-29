# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This Dockerfile creates a production release image for the project. This
# downloads the release from releases.hashicorp.com and therefore requires that
# the release is published before building the Docker image.
#
# We don't rebuild the software because we want the exact checksums and
# binary signatures to match the software and our builds aren't fully
# reproducible currently.
#
# This Dockerfile is different from the regular Dockerfile because it's
# based on Red Hat's UBI image. This Dockerfile is used to build a Consul
# image for use on OpenShift.
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.6

# This is the release of nomad to pull in.
ARG NOMAD_VERSION=1.5.6
ARG CONSUL_TEMPLATE_VERSION=0.32.0

# This is the location of the releases.
ENV HASHICORP_RELEASES=https://releases.hashicorp.com

# Set up certificates, base tools, and Consul.
# dumb-init is downloaded directly from GitHub because there's no RPM package.
# Its shasum is hardcoded. If you upgrade the dumb-init verion you'll need to
# also update the shasum.
RUN set -eux && \
    microdnf install -y ca-certificates curl gnupg libcap openssl iputils jq iptables wget unzip tar && \
    wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 && \
    echo 'e874b55f3279ca41415d290c512a7ba9d08f98041b28ae7c2acb19a545f1c4df /usr/bin/dumb-init' > dumb-init-shasum && \
    sha256sum --check dumb-init-shasum && \
    chmod +x /usr/bin/dumb-init && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys C874011F0AB405110D02105534365D9472D7468F && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    nomadArch=amd64 && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${nomadArch}.zip && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify nomad_${NOMAD_VERSION}_SHA256SUMS.sig nomad_${NOMAD_VERSION}_SHA256SUMS && \
    grep nomad_${NOMAD_VERSION}_linux_${nomadArch}.zip nomad_${NOMAD_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /tmp/build nomad_${NOMAD_VERSION}_linux_${nomadArch}.zip && \
    cp /tmp/build/nomad /bin/nomad && \
    if [ -f /tmp/build/EULA.txt ]; then mkdir -p /usr/share/doc/nomad; mv /tmp/build/EULA.txt /usr/share/doc/nomad/EULA.txt; fi && \
    if [ -f /tmp/build/TermsOfEvaluation.txt ]; then mkdir -p /usr/share/doc/nomad; mv /tmp/build/TermsOfEvaluation.txt /usr/share/doc/nomad/TermsOfEvaluation.txt; fi && \
    cd /tmp && \
    rm -rf /tmp/build && \
# tiny smoke test to ensure the binary we downloaded runs
    nomad version

# Download consul-template
RUN set -eux && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    consulArch=amd64 && \
    wget ${HASHICORP_RELEASES}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_${consulArch}.zip && \
    wget ${HASHICORP_RELEASES}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS && \
    wget ${HASHICORP_RELEASES}/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig && \
    gpg --batch --verify consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS.sig consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS && \
    grep consul-template_${CONSUL_TEMPLATE_VERSION}_linux_${consulArch}.zip consul-template_${CONSUL_TEMPLATE_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /tmp/build consul-template_${CONSUL_TEMPLATE_VERSION}_linux_${consulArch}.zip && \
    cp /tmp/build/consul-template /bin/consul-template && \
    cd /tmp && \
    rm -rf /tmp/build && \
    gpgconf --kill all && \
    rm -rf /root/.gnupg

# Install packages for nomad client to function
RUN microdnf install -y iproute

# Create a non-root user to run the software. On OpenShift, this
# will not matter since the container is run as a random user and group
# but this is kept for consistency with our other images.
RUN groupadd nomad && \
    adduser --uid 100 --system -g nomad nomad

# Add nomad user to group that owns docker socket
# @TODO Add group with matching GID in host and container
# for correct permissions
RUN usermod -aG systemd-coredump nomad

# The /nomad/data dir is used by Consul to store state. The agent will be started
# with /nomad/config as the configuration directory so you can add additional
# config files in that location.
# In addition, change the group of the /nomad directory to 0 since OpenShift
# will always execute the container with group 0.
RUN mkdir -p /nomad/data && \
    mkdir -p /nomad/config && \
    chown -R nomad /nomad && \
    chgrp -R 0 /nomad && chmod -R g+rwX /nomad

# set up nsswitch.conf for Go's "netgo" implementation which is used by Consul,
# otherwise DNS supercedes the container's hosts file, which we don't want.
RUN test -e /etc/nsswitch.conf || echo 'hosts: files dns' > /etc/nsswitch.conf

# Expose the nomad data directory as a volume since there's mutable state in there.
VOLUME /nomad/data

# Server RPC is used for communication between Consul clients and servers for internal
# request forwarding.
EXPOSE 8300

# RPC
EXPOSE 4647

# Gossip
EXPOSE 4648 4648/udp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# OpenShift by default will run containers with a random user, however their
# scanner requires that containers set a non-root user.
USER 100

CMD []