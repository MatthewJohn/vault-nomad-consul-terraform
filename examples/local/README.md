
## Requirements

 * Linux OS with Libvirt/qemu and docker
 * Around 8GB dedicated RAM (machine with 16GB struggles with running the stack, OS, IDE and browser)
 * 32GB free disk space

## Initial setup

```
# Fix bug with freeipa unable to write to /tmp
sudo sysctl fs.protected_regular=0

# Install docker

apt-get update && apt-get install libguestfs-tools --assume-yes

mv backend.tf backend.tf.bak
terraform init
terraform apply -target=module.freeipa -target=module.s3
docker logs -f freeipa
# Wait till initiation

# Add freeipa to hosts file
cat >> /etc/hosts <<EOF
$(docker inspect freeipa | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress') freeipa.dock.local
EOF

# Configure s3
terraform apply -target=module.s3_configure

# Add host file entries
cat >> /etc/hosts <<EOF
$(docker inspect s3 | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress') s3.dock.local
192.168.122.51 nfs-1.dock.local
192.168.122.52 mon-1.dock.local grafana.dock.local
192.168.122.60 vault-1.dock.local vault-1.vault.dock.local vault.dock.local
192.168.122.61 vault-2.dock.local vault-1.vault.dock.local
192.168.122.71 consul-1.dock.local consul-1.dc.consul.dock.local dc1.consul.dock.local
192.168.122.72 consul-2.dock.local consul-2.dc.consul.dock.local dc1.consul.dock.local
192.168.122.73 consul-3.dock.local consul-3.dc.consul.dock.local dc1.consul.dock.local
192.168.122.81 nomad-1.dock.local server.global.nomad.dock.local
192.168.122.82 nomad-2.dock.local server.global.nomad.dock.local
192.168.122.91 nomad-client-1.dock.local client.dc1.global.nomad.dock.local hello-world.web.dc1.global.nomad.dock.local terrareg.web.dc1.global.nomad.dock.local vector.web.dc1.global.nomad.dock.local
EOF

# Take output terraform_access_key/terraform_secret_key and set
export AWS_ACCESS_KEY_ID=7L42ZUALDFVYXSQEQIV4; export AWS_SECRET_ACCESS_KEY=nG7QgmXwlou7iqMq9LZ1lWAySYEJardOIdKBlFev
mv backend.tf.bak backend.tf

terraform apply -target=module.virtual_machines

# Setup initail vault node
terraform apply -target=module.vault-1 -target=module.vault-N

terraform apply -target=module.vault_init -target=module.vault_cluster -var initial_setup=true

terraform apply -target=module.consul_certificate_authority -target=module.dc1

terraform apply -target=module.consul-1 -target=module.consul-X -target=module.consul_bootstrap -target=module.consul_static_tokens -var initial_setup=true

# Since tokens are not provided to the consul servers, the consul containers should be showing:
2023-05-23T04:31:02.077Z [WARN]  agent: Coordinate update blocked by ACLs: accessorID="anonymous token"

# Iterate through each node individually to re-create with ACL tokens
terraform apply -target=module.consul-1
terraform apply -target=module.consul-2

The containers should be showing:
2023-05-23T04:29:42.453Z [WARN]  agent.cache: handling error in Cache.Notify: cache-type=connect-ca-leaf error="rpc error making call: ACL not found" index=0
2023-05-23T04:29:42.454Z [ERROR] agent.server.cert-manager: failed to handle cache update event: error="leaf cert watch returned an error: rpc error making call: ACL not found"

Again manually restart each of the consul containers

# Nomad
terraform-1.4.6 apply -target=module.nomad_global -target=module.nomad-1 -var initial_setup=true
terraform-1.4.6 apply -target=module.nomad_bootstrap -var initial_setup=true
terraform-1.4.6 apply -target=module.nomad-2
terraform-1.4.6 apply -target=module.nomad-1

terraform-1.4.6 apply -target=module.nomad-client-1

# Configure monitoring
terraform-1.4.6 apply -target=module.grafana -target=module.victoriametrics -target=module.loki
## Configure grafana, once started
terraform-1.4.6 apply -target=module.grafana_configure


# Apply remaining modules
terraform-1.4.6 apply

```

## NOTES:

### Initial VM creation

When a new VM is created, libvirt can error about an unknown disk - the VM has been created and the disk attrached.

The storage pool simply needs refreshing.

This may be fixed by creation of a volume resource in future

### Vault token errors

If you get errors, such as:
```
│ URL: GET https://vault.dock.local:8200/v1/auth/token/lookup-self
│ Code: 403. Errors:
│ 
│ * permission denied
│ 
│   with module.consul_certificate_authority.provider["registry.terraform.io/hashicorp/vault"],
│   on ../../modules/consul/certificate_authority/provider.tf line 1, in provider "vault":
│    1: provider "vault" {
│ 
╵
╷
│ Error: Error making API request.
│ 
│ URL: GET https://vault.dock.local:8200/v1/auth/token/lookup-self
│ Code: 403. Errors:
│ 
│ * permission denied
│ 
│   with module.dc1.provider["registry.terraform.io/hashicorp/vault"],
│   on ../../modules/consul/datacenter/provider.tf line 10, in provider "vault":
│   10: provider "vault" {
│ 
```

Regenerate tokens, using:

```
terraform apply -target=module.vault_cluster
```

### Restarting consul node

When restarting a consul node, you will receive the following errors:
```
2023-05-23T04:32:53.500Z [WARN] (view) vault.read(consul-dc1/creds/consul-server-role): vault.read(consul-dc1/creds/consul-server-role): Error making API request.

URL: GET https://vault.dock.local:8200/v1/consul-dc1/creds/consul-server-role
Code: 400. Errors:

* Unexpected response code: 500 (rpc error getting client: failed to get conn: dial tcp 192.168.122.73:0->192.168.122.72:8300: connect: connection refused) (retry attempt 1 after "250ms")
```
This occurs when the DNS finds the local machine, which is not currently running

```
2023-05-23T04:33:01.465Z [WARN] (view) vault.read(consul-dc1/creds/consul-server-role): vault.read(consul-dc1/creds/consul-server-role): Error making API request.

URL: GET https://vault.dock.local:8200/v1/consul-dc1/creds/consul-server-role
Code: 400. Errors:

* Unexpected response code: 500 (Raft leader not found in server lookup mapping) (retry attempt 6 after "8s")
```

This occurs when the cluster is still recovering from the lost node



## Errors to investigate

consul:
```
2023-05-23T06:02:56.429Z [WARN]  agent.server.raft: failed to get previous log: previous-index=3104 last-index=3085 error="log not found"
```

consul-agent on nomad-client
```
2023-05-31T16:18:33.651Z [INFO]  agent: Synced check: check=service:_nomad-task-386c0164-0d29-767b-9342-89b1d8c74ca7-group-servers-hello-world-servers-www-sidecar-proxy:2
2023-05-31T16:18:33.654Z [ERROR] agent.client: RPC failed to server: method=Catalog.Register server=192.168.122.71:8300 error="rpc error making call: rpc error making call: Permission denied: token with AccessorID '9e605546-aee1-7642-1d6d-cabfdf990c7d' lacks permission 'service:write' on \"nomad-global-client\""
2023-05-31T16:18:33.679Z [WARN]  agent: Check registration blocked by ACLs: check=_nomad-check-3f04a896e88b1a64f3e32128778f4f007a49ea21 accessorID=9e605546-aee1-7642-1d6d-cabfdf990c7d
2023-05-31T16:18:33.685Z [ERROR] agent.client: RPC failed to server: method=Catalog.Register server=192.168.122.73:8300 error="rpc error making call: rpc error making call: Permission denied: token with AccessorID '049cd196-93cd-cb26-24ea-b27c08f0b116' lacks permission 'service:write' on \"nomad-global-dc1-client\""
2023-05-31T16:18:33.708Z [WARN]  agent: Check registration blocked by ACLs: check=_nomad-check-b7911a41cc366cb9ab916133e60fff8182525f5e accessorID=049cd196-93cd-cb26-24ea-b27c08f0b116
2023-05-31T16:18:33.718Z [INFO]  agent: Synced check: check=service:_nomad-task-386c0164-0d29-767b-9342-89b1d8c74ca7-group-servers-hello-world-servers-www-sidecar-proxy:1
2023-05-31T16:18:35.316Z [ERROR] agent.client: RPC failed to server: method=Catalog.Register server=192.168.122.72:8300 error="rpc error making call: Permission denied: token with AccessorID '9e605546-aee1-7642-1d6d-cabfdf990c7d' lacks permission 'service:write' on \"nomad-global-client\""
2023-05-31T16:18:35.317Z [WARN]  agent: Check registration blocked by ACLs: check=_nomad-check-3f04a896e88b1a64f3e32128778f4f007a49ea21 accessorID=9e605546-aee1-7642-1d6d-cabfdf990c7d
2023-05-31T16:18:35.335Z [INFO]  agent: Synced check: check=service:_nomad-task-386c0164-0d29-767b-9342-89b1d8c74ca7-group-servers-hello-world-servers-www-sidecar-proxy:1
2023-05-31T16:18:36.009Z [INFO]  agent: Synced service: service=_nomad-task-386c0164-0d29-767b-9342-89b1d8c74ca7-group-servers-hello-world-servers-www-sidecar-proxy
2023-05-31T16:18:41.863Z [ERROR] agent.client: RPC failed to server: method=Catalog.Register server=192.168.122.71:8300 error="rpc error making call: rpc error making call: Permission denied: token with AccessorID '9e605546-aee1-7642-1d6d-cabfdf990c7d' lacks permission 'service:write' on \"nomad-global-client\""
2023-05-31T16:18:41.864Z [WARN]  agent: Check registration blocked by ACLs: check=_nomad-check-3f04a896e88b1a64f3e32128778f4f007a49ea21 accessorID=9e605546-aee1-7642-1d6d-cabfdf990c7d
2023-05-31T16:18:43.864Z [INFO]  agent: Synced check: check=service:_nomad-task-386c0164-0d29-767b-9342-89b1d8c74ca7-group-servers-hello-world-servers-www-sidecar-proxy:1
2023-05-31T16:20:41.151Z [ERROR] agent.envoy: Error receiving new DeltaDiscoveryRequest; closing request channel: error="rpc error: code = Canceled desc = context canceled"
2023-05-31T16:20:42.107Z [WARN]  agent: Check is now critical: check=_nomad-check-3f04a896e88b1a64f3e32128778f4f007a49ea21
2023-05-31T16:20:42.113Z [ERROR] agent.client: RPC failed to server: method=Catalog.Register server=192.168.122.73:8300 error="rpc error making call: rpc error making call: Permission denied: token with AccessorID '9e605546-aee1-7642-1d6d-cabfdf990c7d' lacks permission 'service:write' on \"nomad-global-client\""
2023-05-31T16:20:42.118Z [WARN]  agent: Check registration blocked by ACLs: check=_nomad-check-3f04a896e88b1a64f3e32128778f4f007a49ea21 accessorID=9e605546-aee1-7642-1d6d-cabfdf990c7d
```
consul-agent on nomad-client:
```
2023-05-31T16:31:32.042Z [ERROR] agent.http: Request error: method=GET url=/v1/config/proxy-defaults/global from=127.0.0.1:41134 error="Config entry not found for \"proxy-defaults\" / \"global\""
```


## Startup after poweroff:

1. Start vault hosts (@TODO Make containers start on boot)
2. Start consul hosts
3. Setup consul to bootstrap:
```
terraform apply -target=module.consul-1 -target=module.consul-X -var initial_setup=true
```
4. Restart each noamd container
```
terraform apply -target=module.consul-1
terraform apply -target=module.consul-X
etc.
```
5. Start nomad hosts
6. Start noamd clients

## Recovering 2 node vault cluster after one node has been rebuild

On the node with valid data:

```
cat > /vault/raft/raft/peers.json <<EOF
[
  {
    "id": "$(hostname)",
    "address": "$(hostname).vault.$(hostname -d):8201",
    "non_voter": false
  }
]
EOF
docker restart vault
```
