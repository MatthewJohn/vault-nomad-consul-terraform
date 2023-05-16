
## Initial setup

```
terraform init
terraform apply -target=module.freeipa_initial_setup
docker logs -f freeipa-setup
# Wait till completion

terraform apply -target=module.freeipa
docker logs -f freeipa
# Wait till initiation
```

