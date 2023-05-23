
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

```

## NOTES:

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

## Restarting consul node

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

