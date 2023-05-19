#!/bin/bash

set -e

vault_host=$1
vault_ssh_username=$2
aws_profile=$3
aws_region=$4
aws_endpoint=$5
bucket_name=$6
autoseal_file_key=$7
initial_run=$8

ca_cert_file="`pwd`/root_ca.pem"
root_tokens_json_file="`pwd`/recovery_tokens-${vault_host}.json"
vault_unseal_debug_file="`pwd`/unseal-debug-${vault_host}.log"
vault_unwrapped_token_file="`pwd`/unwrapped_token-${vault_host}.json"
auto_unseal_token_file="`pwd`/auto_unseal.json"
root_token=""

current_vault_host=$vault_host

function f_execute_vault_command() {
    ssh docker-connect@${current_vault_host} \
        docker exec \
        -e VAULT_TOKEN=$root_token \
        -e VAULT_CACERT=/vault/ssl/root-ca.pem \
        vault \
        $@

    return $?
}

echo "Starting secondary" > $vault_unseal_debug_file

if [ "$(f_execute_vault_command vault status | grep -E '^Sealed' | awk '{ print $2 }')" != "true" ]
then
  echo "Already unsealed" >> $vault_unseal_debug_file
  exit 0
fi

echo "Downloading auto unseal tokens from s3" >> $vault_unseal_debug_file
aws s3 cp s3://${bucket_name}/${autoseal_file_key} ${auto_unseal_token_file} \
    --endpoint="$aws_endpoint" --profile="$aws_profile" \
    --region="$aws_region" >> $vault_unseal_debug_file 2>&1
echo "Downloaded" >> $vault_unseal_debug_file

root_token=$(cat ${auto_unseal_token_file} | jq -r '.wrap_info.token')

echo "Unrwapping token" >> $vault_unseal_debug_file
current_vault_host=vault-1.dock.local
f_execute_vault_command vault unwrap -format=json > $vault_unwrapped_token_file 2>> $vault_unseal_debug_file
current_vault_host=${vault_host}
echo "Unwrapped token" >> $vault_unseal_debug_file

unseal_token=$(cat ${vault_unwrapped_token_file} | jq -r '.auth.client_token')

# Copy unseal token to docker host
ssh docker-connect@$vault_host "echo $unseal_token > /vault/config.d/unseal-token" >> $vault_unseal_debug_file

# Restart container
ssh docker-connect@$vault_host "docker restart vault" >> $vault_unseal_debug_file

#f_execute_vault_command vault operator unseal $unseal_token
# Init
# echo "Performing operator init" >> $vault_unseal_debug_file
# f_execute_vault_command vault operator init -format=json > ${root_tokens_json_file}
# echo "Operator init success" >> $vault_unseal_debug_file

# # Upload recovery tokens to s3
# echo "Uploading root tokens to s3" >> $vault_unseal_debug_file
# aws s3 cp ${root_tokens_json_file} s3://${bucket_name}/recovery_tokens-${vault_host}.json \
#     --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $vault_unseal_debug_file

echo '{}'

