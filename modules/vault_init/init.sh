#!/bin/bash

vault_host=$1
vault_ssh_username=$2
aws_profile=$3
aws_region=$4
aws_endpoint=$5
bucket_name=$6
bucket_key=$7
initial_run=$8

ca_cert_file="`pwd`/root_ca.pem"
root_tokens_json_file="`pwd`/root_tokens.json"

# Obtain Root SSL cert, if it's not downloaded
if [ ! -f "$ca_cert_file" ]
then
    echo "Downloading root certificate" >&2
    aws s3 cp s3://root-ca-certs/vault/root_ca.pem ./ \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region"  >/dev/null
fi

# Attempt to download existing root credentials
echo "Attempting to download root tokens" >&2
if aws s3 cp s3://${bucket_name}/${bucket_key} ${root_tokens_json_file} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region"  >/dev/null
then
    root_token=$(cat "$root_tokens_json_file" | jq .root_token)

elif [ "$initial_run" == "0" ]
then
    echo "Cannot find root credentials on non-initial run" >&2
    exit 1
else

    echo "Checking if vault is initialised" >&2
    set +e
    ssh docker-connect@${vault_host} \
        docker exec -e VAULT_CACERT=/vault/ssl/root-ca.pem \
        vault vault operator init -status >/dev/null
    vault_init_status=$?
    set -e

    if [ "$vault_init_status" == "0" ]
    then
        echo "Vault status indicates it is already initialised" >&2
        exit 1
    elif [ "$vault_init_status" == "1" ]
    then
        echo "Vault status indicates an error has occurred" >&2
        exit 1
    fi

    echo "Setting up initial credentials" >&2
    ssh docker-connect@${vault_host} \
        docker exec \
        -e VAULT_CACERT=/vault/ssl/root-ca.pem \
        vault \
        vault operator init \
        -key-shares=1 -key-threshold=1 \
        -format=json > ${root_tokens_json_file}

    aws s3 cp ${root_tokens_json_file} s3://${bucket_name}/${bucket_key} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >/dev/null
fi


echo '{"root_token": "hvs.80AD9tTqbn3Z8DU6WumZ51yK", "ca_cert_file": "'$ca_cert_file'"}'

