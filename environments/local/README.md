
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

# Add hosts entry for freeipa.dock.local:
echo $(docker inspect freeipa | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress') freeipa.dock.local >> /etc/hosts


# Configure s3
terraform apply -target=module.s3_configure
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
2023-05-23T06:03:04.948Z [ERROR] agent: Failed to check for updates: error="Get \"https://checkpoint-api.hashicorp.com/v1/check/consul?arch=amd64&os=linux&signature=e54f3d7f-3cc0-31f7-374c-d7bccbfbab8a&version=1.15.2\": context deadline exceeded (Client.Timeout exceeded while awaiting headers)"
```