#!/bin/bash

set -e

vault_host=$1
vault_ssh_username=$2
aws_profile=$3
aws_region=$4
aws_endpoint=$5
bucket_name=$6
bucket_key=$7
initial_run=$8

ca_cert_file="`pwd`/root_cert.pem"
export AWS_CA_BUNDLE=$ca_cert_file
root_tokens_json_file="`pwd`/root_tokens.json"
vault_unseal_debug_file="`pwd`/unseal-debug.log"
root_token=""

function f_execute_vault_command() {
    ssh docker-connect@${vault_host} \
        docker exec \
        -e VAULT_TOKEN=$root_token \
        -e VAULT_CACERT=/vault/ssl/root-ca.pem \
        vault \
        $@

    return $?
}


echo "Starting unseal" > $vault_unseal_debug_file


# Attempt to download existing root credentials
echo "Attempting to download root tokens" >> $vault_unseal_debug_file
if aws s3 cp s3://${bucket_name}/${bucket_key} ${root_tokens_json_file} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $vault_unseal_debug_file
then
    echo "Root credentials downloaded" >> $vault_unseal_debug_file

elif [ "$initial_run" == "0" ]
then
    echo "Cannot find root credentials on non-initial run" >> $vault_unseal_debug_file
    exit 1
else

    echo "Checking if vault is initialised" >> $vault_unseal_debug_file
    set +e
    f_execute_vault_command vault operator init -status >> $vault_unseal_debug_file
    vault_init_status=$?
    set -e

    if [ "$vault_init_status" == "0" ]
    then
        echo "Vault status indicates it is already initialised" >> $vault_unseal_debug_file
        exit 1
    elif [ "$vault_init_status" == "1" ]
    then
        echo "Vault status indicates an error has occurred" >> $vault_unseal_debug_file
        exit 1
    fi

    echo "Setting up initial credentials" >> $vault_unseal_debug_file
    f_execute_vault_command vault operator init \
        -recovery-shares=5 -recovery-threshold=3 \
        -format=json > ${root_tokens_json_file}

    echo "Uploading root tokens to s3" >> $vault_unseal_debug_file
    aws s3 cp ${root_tokens_json_file} s3://${bucket_name}/${bucket_key} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $vault_unseal_debug_file
fi

# Get current sealed status
sealed_status=$(f_execute_vault_command vault status | grep -E '^Sealed' | awk '{ print $2 }')
if [ "$sealed_status" == "true" ]
then
    echo "Vault is sealed... unsealing" >> $vault_unseal_debug_file
    # @TODO Add support for multiple keys
    f_execute_vault_command vault operator unseal $(cat ${root_tokens_json_file} | jq -r '.unseal_keys_b64[0]') >> $vault_unseal_debug_file 2>&1
    echo "Unsealed vault" >> $vault_unseal_debug_file
else
    echo "Vault is already unsealed" >> $vault_unseal_debug_file
fi


root_token=$(cat ${root_tokens_json_file} | jq -r '.root_token')

ca_cert=$(cat $ca_cert_file | sed 's/$/\\n/g' | tr -d '\n')

# rm -f ${root_tokens_json_file}

echo "{\"root_token\": \"$root_token\", \"ca_cert_file\": \"${ca_cert_file}\", \"ca_cert\": \"$ca_cert\"}"
