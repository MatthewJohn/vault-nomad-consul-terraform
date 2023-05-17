
## Initial setup

```
# Fix bug with freeipa unable to write to /tmp
sudo sysctl fs.protected_regular=0

# Install docker

apt-get update && apt-get install libguestfs-tools --assume-yes

terraform init
terraform apply -target=module.freeipa
docker logs -f freeipa
# Wait till initiation

# Add hosts entry for freeipa.dock.local:
echo $(docker inspect freeipa | jq -r '.[0].NetworkSettings.Networks.bridge.IPAddress') freeipa.dock.local >> /etc/hosts

terraform apply

```

