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

ca_cert_file="`pwd`/root_ca.pem"
root_tokens_json_file="`pwd`/root_tokens.json"
vault_unseal_debug_file="`pwd`/unseal-debug.log"
auto_unseal_token_file="`pwd`/auto_unseal.json"
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

# Obtain Root SSL cert, if it's not downloaded
if [ ! -f "$ca_cert_file" ]
then
    echo "Downloading root certificate" >> $vault_unseal_debug_file
    aws s3 cp s3://root-ca-certs/vault/root_ca.pem ./ \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $vault_unseal_debug_file
fi

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
        -key-shares=1 -key-threshold=1 \
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

# Setup unseal store
echo "Checking vault transit enabled" >> $vault_unseal_debug_file
if ! f_execute_vault_command vault secrets list | grep -E '^transit' >/dev/null 2>&1
then
    echo "Enabling vault transit" >> $vault_unseal_debug_file
    f_execute_vault_command vault secrets enable transit >> $vault_unseal_debug_file 2>&1
    echo $? >> $vault_unseal_debug_file
fi

echo "Checking autounseal keys" >> $vault_unseal_debug_file
if ! f_execute_vault_command vault list transit/keys | grep '^autounseal$' >/dev/null 2>&1
then
    echo "Creating autounseal keys" >> $vault_unseal_debug_file
    f_execute_vault_command vault write -f transit/keys/autounseal >> $vault_unseal_debug_file 2>&1

    echo "Creating policy" >> $vault_unseal_debug_file
    cat > ./auto_unseal_policy.json <<EOF
path "transit/encrypt/autounseal" {
   capabilities = [ "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "update" ]
}
EOF
    scp ./auto_unseal_policy.json docker-connect@${vault_host}:~/ >> $vault_unseal_debug_file 2>&1
    ssh docker-connect@${vault_host} docker cp ./auto_unseal_policy.json vault:/vault/ >> $vault_unseal_debug_file 2>&1
    f_execute_vault_command vault policy write autounseal /vault/auto_unseal_policy.json >> $vault_unseal_debug_file 2>&1
    echo "Created policy" >> $vault_unseal_debug_file
fi

echo "Creating unseal token" >> $vault_unseal_debug_file
f_execute_vault_command vault token create -orphan \
    -policy="autounseal" -format=json \
    -wrap-ttl=120 -period=24h > $auto_unseal_token_file 2>> $vault_unseal_debug_file

echo "Uploading auto unseal tokens to s3" >> $vault_unseal_debug_file
aws s3 cp ${auto_unseal_token_file} s3://${bucket_name}/auto_unseal.json \
    --endpoint="$aws_endpoint" --profile="$aws_profile" \
    --region="$aws_region" >> $vault_unseal_debug_file 2>&1

echo "{\"root_token\": \"$root_token\", \"ca_cert_file\": \"${ca_cert_file}\"}"
