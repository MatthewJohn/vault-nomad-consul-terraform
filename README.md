# vault-nomad-consul-terraform

## Overview

This project attempts to provide an entire vault/consul/nomad stack.

It uses the following:
 * Libvirt for creating virtual machines, using docker
 * FreeIPA (core DNS)
 * Minio (s3) (store state, CA certs and bootstrap tokens)
 * openkms for autounseal on KMS (requires improvement to further secure)
 * Vault
 * Consul
 * Nomad (servers and clients)
 * Consul connect service mesh
 * Traefik service for ingress traffic
 * consul-template (for provisioning CA certificates)

It attempts to provide:
 * ACLs with minimum required privileges
 * Root CAs for each stack
 * Ability to handle multiple datacenter (vault/consul) and regions (nomad)
 * Absolutely no manual interactions except:
   * Currently requires several terraform runs with arguments to protect against accidental re-initialisation of services)
   * Reqiures manual initial SSH connection to new servers to accept host SSH key

## Usage

Current setup for local

```
cd environments/local
```

See environment/local/README.md for more information

## Progress

 * Create virtual machines with cloudinit initial setup - Done
 * Create/configure FreeIPA - Done
 * Setup s3 - Done 
 * Create vault cluster/boostrap - Done
 * Create consul cluster/boostrap - Done
 * Add vault backups
 * Complete nomad setup - Done
 * Complete consul-connect setup - Done
 * Investigate consul using consul as connect CA
 * Further securing of KMS for vault autounseal

## Design

### Consul server

Consul server hosts run vault agent - this allows the vault token to be automatically regenerated through the consule-server's consul-template approle.

consul template runs in the consul container, which uses the sink from vault-agent to generate SSL certificates. This allows new certificates to be generated and automatically restart the consul container.

