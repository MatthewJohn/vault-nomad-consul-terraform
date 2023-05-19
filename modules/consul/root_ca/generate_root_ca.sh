#!/bin/bash

set -e

consul_binary=$1
bucket_name=$2
bucket_prefix=$3
aws_profile=$4
aws_region=$5
aws_endpoint=$6

public_key_file="consul-agent-ca.pem"
private_key_file="consul-agent-ca-key.pem"

if ! { aws s3 cp s3://$bucket_name/$bucket_prefix/$public_key_file ./ \
        --profile $aws_profile --region $aws_region \
        --endpoint $aws_endpoint >/dev/null \
    && aws cp s3://$bucket_name/$bucket_prefix/$private_key_file ./ \
        --profile $aws_profile --region $aws_region \
        --endpoint $aws_endpoint >/dev/null; }
then
    # Remove any local files
    rm -f $public_key_file $private_key_file

    # Generate root CA
    $consul_binary tls ca create >/dev/null

    # Upload to s3
    aws s3 cp ./$private_key_file s3://$bucket_name/$bucket_prefix/ \
        --profile $aws_profile --region $aws_region \
        --endpoint $aws_endpoint >/dev/null
    aws s3 cp ./$public_key_file s3://$bucket_name/$bucket_prefix/ \
        --profile $aws_profile --region $aws_region \
        --endpoint $aws_endpoint >/dev/null
fi

public_cert=$(cat $public_key_file | sed ':a;N;$!ba;s/\n/\\n/g' )
private_key=$(cat $private_key_file | sed ':a;N;$!ba;s/\n/\\n/g' )

rm -f $public_key_file $private_key_file

echo "{\"public_key\": \"$public_cert\", \"private_key\": \"$private_key\"}"
