#!/bin/bash

set -e

consul_host=$1
consul_ssh_username=$2
aws_profile=$3
aws_region=$4
aws_endpoint=$5
bucket_name=$6
bucket_key=$7
initial_run=$8

ca_cert_file="`pwd`/root_cert.pem"
export AWS_CA_BUNDLE=$ca_cert_file
bootstrap_tokens_json_file="`pwd`/consul_bootstrap.json"
consul_unseal_debug_file="`pwd`/bootstrap-debug.log"
root_token=""

function f_execute_consul_command() {
    ssh docker-connect@${consul_host} \
        docker exec \
        -e consul_TOKEN=$root_token \
        -e consul_CACERT=/consul/ssl/root-ca.pem \
        consul \
        $@

    return $?
}

echo "Starting unseal" > $consul_unseal_debug_file

# Attempt to download existing bootstrap credentials
echo "Attempting to download bootstrap tokens" >> $consul_unseal_debug_file
if aws s3 cp s3://${bucket_name}/${bucket_key} ${bootstrap_tokens_json_file} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $consul_unseal_debug_file
then
    echo "bootstrap credentials downloaded" >> $consul_unseal_debug_file

elif [ "$initial_run" == "0" ]
then
    echo "Cannot find bootstrap credentials on non-initial run" >> $consul_unseal_debug_file
    exit 1
else
    echo "Performing bootstrap" >> $consul_unseal_debug_file
    f_execute_consul_command consul acl bootstrap \
        -format=json > ${bootstrap_tokens_json_file}

    echo "Uploading root tokens to s3" >> $consul_unseal_debug_file
    aws s3 cp ${bootstrap_tokens_json_file} s3://${bucket_name}/${bucket_key} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $consul_unseal_debug_file
fi

token=$(cat ${bootstrap_tokens_json_file} | jq -r '.SecretID')

rm ${bootstrap_tokens_json_file}

echo "{\"token\": \"${token}\"}"
