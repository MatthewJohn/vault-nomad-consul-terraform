
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

# Iterate through each node individually to re-create with ACL tokens
terraform apply -target=module.consul-1
terraform apply -target=module.consul-2

```

## NOTES:


### Error 1

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

### Error 2

```
╷
│ Error: failed to read policy '124de1ce-67f3-acee-484d-23fcd34dda4e': Unexpected response code: 500 (No cluster leader)
│ 
│   with module.consul_static_tokens.consul_acl_policy.agent_role["consul-1"],
│   on ../../modules/consul/static_tokens/agent_token.tf line 1, in resource "consul_acl_policy" "agent_role":
│    1: resource "consul_acl_policy" "agent_role" {
│ 
╵
╷
│ Error: failed to read policy '00404993-1fd1-f3bc-7bec-1b0e57c13972': Unexpected response code: 500 (No cluster leader)
│ 
│   with module.consul_static_tokens.consul_acl_policy.agent_role["consul-2"],
│   on ../../modules/consul/static_tokens/agent_token.tf line 1, in resource "consul_acl_policy" "agent_role":
│    1: resource "consul_acl_policy" "agent_role" {
│ 
╵
```

Solution:

Reconfigure and re-apply tokens for consul hosts to bring them back up, if this is the issue with the consul containers
```
terraform apply -target=module.consul-1 -target=module.consul-X
```
