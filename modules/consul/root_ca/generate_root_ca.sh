#!/bin/bash

set -e

consul_binary=$1
bucket_name=$2
bucket_prefix=$3
aws_profile=$4
aws_region=$5
aws_endpoint=$6
common_name=$7
domain=$8
expiry_days=$9
initial_run=${10}
additional_domains=${11}

public_key_file="${domain}-agent-ca.pem"
private_key_file="${domain}-agent-ca-key.pem"

additional_domains_params=$(echo $additiona_domains | sed 's/,/ -additional-name-constraint=/g')
if [ "$additional_domains_params" != "" ]
then
    additional_domains_params="-additional-name-constraint=$additional_domains_params"
fi

# Remove any local CA files
rm -f $public_key_file $private_key_file

aws s3 cp s3://$bucket_name/$bucket_prefix/$public_key_file ./ \
        --profile $aws_profile --region $aws_region \
        --endpoint $aws_endpoint >/dev/null || true

aws s3 cp s3://$bucket_name/$bucket_prefix/$private_key_file ./ \
        --profile $aws_profile --region $aws_region \
        --endpoint $aws_endpoint >/dev/null || true

if [ ! -f "$private_key_file" ] || [ ! -f "$public_key_file" ]
then
    if [ "$initial_run"  != "1" ]
    then
        echo "Could not find Root CA on non-initial run" >&2
        exit 1
    fi

    # Remove any local files
    rm -f $public_key_file $private_key_file

    # Generate root CA
    $consul_binary tls ca create \
        -domain "$domain" -common-name "$common_name" \
        -name-constraint \
        -days $expiry_days \
        $additional_domains_params >/dev/null

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

echo "{\"public_key\": \"$bucket_prefix/$public_key_file\", \"private_key\": \"$bucket_prefix/$private_key_file\"}"
