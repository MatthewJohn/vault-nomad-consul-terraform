# vault-nomad-consul-terraform

Current setup for local

```
cd environments/local
```

See environment/local/README.md for more information

TODO

 * Add vault backups



## Design

### Consul server

Consul server hosts run vault agent - this allows the vault token to be automatically regenerated through the consule-server's consul-template approle.

consul template runs in the consul container, which uses the sink from vault-agent to generate SSL certificates. This allows new certificates to be generated and automatically restart the consul container.

