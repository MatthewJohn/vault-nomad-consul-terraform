
## Initial setup

```
# Fix bug with freeipa unable to write to /tmp
sudo sysctl fs.protected_regular=0

terraform init
terraform apply -target=module.freeipa
docker logs -f freeipa
# Wait till initiation
```

