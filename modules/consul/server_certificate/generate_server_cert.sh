#!/bin/bash

set -e
set -x

TEMP_DIR=$(mktemp -d)
DEBUG="true"

trap 'error_handler $? $LINENO' ERR

# Catch any errors and remove temp dir
error_handler() {
    echo "Error: ($1) occurred on $2" >&2
    popd  >/dev/null || true

    if [ "$DEBUG" == "false" ]
    then
        rm -rf $TEMP_DIR
    else
        echo "DEBUG: Leaving temp dir: ${TEMP_DIR}" >&2
    fi
}

consul_binary=$1
bucket_name=$2
bucket_prefix=$3
aws_profile=$4
aws_region=$5
aws_endpoint=$6
initial_run=$7
ip_address=$8
ca_root_public_s3_key=$9
ca_root_private_s3_key=${10}
expiry_days=${11}
datacenter=${12}
domain=${13}
hostname=${14}
additional_domains=${15}

public_key_s3_key="${hostname}-${datacenter}-${domain}-server.pem"
private_key_s3_key="${hostname}-${datacenter}-${domain}-server-key.pem"
public_key_file="${datacenter}-server-${domain}-0.pem"
private_key_file="${datacenter}-server-${domain}-0-key.pem"

ca_public_key_file="${hostname}-${datacenter}-${domain}-ca.pem"
ca_private_key_file="${hostname}-${datacenter}-${domain}-ca-key.pem"

additional_domains_params=$(echo $additiona_domains | sed 's/,/ -additional-dnsname=/g')
if [ "$additional_domains_params" != "" ]
then
    additional_domains_params="-additional-dnsname=$additional_domains_params"
fi

tf_work_dir=`pwd`

pushd $TEMP_DIR >/dev/null

    aws s3 cp s3://$bucket_name/$bucket_prefix/$public_key_s3_key ./$public_key_file \
            --profile $aws_profile --region $aws_region \
            --endpoint $aws_endpoint >/dev/null || true

    aws s3 cp s3://$bucket_name/$bucket_prefix/$private_key_s3_key ./$private_key_file \
            --profile $aws_profile --region $aws_region \
            --endpoint $aws_endpoint >/dev/null || true

    if [ ! -f "$private_key_file" ] || [ ! -f "$public_key_file" ]
    then
        if [ "$initial_run"  != "1" ]
        then
            echo "Could not find server cert on non-initial run" >&2
            exit 1
        fi

        # Download root CA certs
        aws s3 cp s3://$bucket_name/$bucket_prefix/$ca_root_public_s3_key ./$ca_public_key_file \
                --profile $aws_profile --region $aws_region \
                --endpoint $aws_endpoint >/dev/null

        aws s3 cp s3://$bucket_name/$bucket_prefix/$ca_root_private_s3_key ./$ca_private_key_file \
                --profile $aws_profile --region $aws_region \
                --endpoint $aws_endpoint >/dev/null

        # Remove any local files
        rm -f $public_key_file $private_key_file

        # Generate server cert
        $tf_work_dir/$consul_binary tls cert create \
            -additional-ipaddress=$ip_address \
            -ca=$ca_public_key_file -key=$ca_private_key_file \
            -server \
            -dc=$datacenter \
            -domain=$domain \
            -node=$hostname \
            -days=$expiry_days \
            $additional_domains_params >/dev/null

        # Upload to s3
        aws s3 cp ./$private_key_file s3://$bucket_name/$bucket_prefix/$private_key_s3_key \
            --profile $aws_profile --region $aws_region \
            --endpoint $aws_endpoint >/dev/null
        aws s3 cp ./$public_key_file s3://$bucket_name/$bucket_prefix/$public_key_s3_key \
            --profile $aws_profile --region $aws_region \
            --endpoint $aws_endpoint >/dev/null
    fi

    rm -f $public_key_file $private_key_file

popd >/dev/null

rm -rf $TEMP_DIR

echo "{\"public_key\": \"$public_key_s3_key\", \"private_key\": \"$private_key_s3_key\", \"bucket_prefix\": \"${bucket_prefix}\"}"
