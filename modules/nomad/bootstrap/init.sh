#!/bin/bash

set -e

nomad_host=$1
nomad_ssh_username=$2
nomad_port=$3
aws_profile=$4
aws_region=$5
aws_endpoint=$6
bucket_name=$7
bucket_key=$8
initial_run=$9

ca_cert_file="`pwd`/root_ca.pem"
bootstrap_tokens_json_file="`pwd`/nomad_bootstrap.json"
nomad_unseal_debug_file="`pwd`/nomad-bootstrap-debug.log"
root_token=""

function f_execute_nomad_command() {
    ssh docker-connect@${nomad_host} \
        docker exec \
        -e NOMAD_TOKEN=$root_token \
        -e NOMAD_CACERT=/nomad/config/server-certs/ca.crt \
        -e NOMAD_ADDR=https://localhost:${nomad_port} \
        nomad \
        $@

    return $?
}

echo "Starting bootstrapping" > $nomad_unseal_debug_file

# Attempt to download existing bootstrap credentials
echo "Attempting to download bootstrap tokens" >> $nomad_unseal_debug_file
if aws s3 cp s3://${bucket_name}/${bucket_key} ${bootstrap_tokens_json_file} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $nomad_unseal_debug_file
then
    echo "bootstrap credentials downloaded" >> $nomad_unseal_debug_file

elif [ "$initial_run" == "0" ]
then
    echo "Cannot find bootstrap credentials on non-initial run" >> $nomad_unseal_debug_file
    exit 1
else
    echo "Performing bootstrap" >> $nomad_unseal_debug_file
    f_execute_nomad_command nomad acl bootstrap \
        -json > ${bootstrap_tokens_json_file}

    echo "Uploading root tokens to s3" >> $nomad_unseal_debug_file
    aws s3 cp ${bootstrap_tokens_json_file} s3://${bucket_name}/${bucket_key} \
      --endpoint="$aws_endpoint" --profile="$aws_profile" --region="$aws_region" >> $nomad_unseal_debug_file
fi

token=$(cat ${bootstrap_tokens_json_file} | jq -r '.SecretID')

rm ${bootstrap_tokens_json_file}

echo "{\"token\": \"${token}\"}"
