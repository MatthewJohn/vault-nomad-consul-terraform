
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


# Setup initail vault node
terraform apply -target=module.vault-1 -target=module.vault-N -var initial_setup=true

# Configure vault
ssh docker-connect@vault-1.dock.local docker exec -ti -e VAULT_CACERT=/vault/ssl/root-ca.pem -e VAULT_URL=https://vault-1.vault.dock.local:8200 vault vault operator init -key-shares=5 -key-threshold=3

```

