#!/bin/sh
while getopts n:r:v:a:k:s:h: option
do
 case "${option}" in
 n) REDIS_NAME=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 v) VAULT_NAME=${OPTARG};;
 a) ACCESS_KEY_SECRET_NAME=${OPTARG};;
 k) ACCESS_KEY=${OPTARG};;
 s) HOSTNAME_SECRET_NAME=${OPTARG};;
 h) HOSTNAME=${OPTARG};;
  *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $REDIS_NAME ]; then
    echo "REDIS_NAME is empty"
    exit 1;
elif [ -z $RESOURCE_GROUP_NAME ]; then
    echo "RESOURCE_GROUP_NAME is empty"
    exit 1;
elif [ -z $VAULT_NAME ]; then
    echo "VAULT_NAME is empty"
    exit 1;
elif [ -z $ACCESS_KEY_SECRET_NAME ]; then
    echo "ACCESS_KEY_SECRET_NAME is empty"
    exit 1;
elif [ -z $ACCESS_KEY ]; then
    echo "ACCESS_KEY is empty"
    exit 1;
elif [ -z $HOSTNAME_SECRET_NAME ]; then
    echo "HOSTNAME_SECRET_NAME is empty"
    exit 1;
elif [ -z $HOSTNAME ]; then
    echo "HOSTNAME is empty"
    exit 1;
else
    echo "Input is valid"
fi

echo "set redis access key secret: $ACCESS_KEY_SECRET_NAME"
az keyvault secret set --vault-name $VAULT_NAME --name $ACCESS_KEY_SECRET_NAME --value $ACCESS_KEY --output none

echo "set redis hostname secret: $HOSTNAME_SECRET_NAME"
az keyvault secret set --vault-name $VAULT_NAME --name $HOSTNAME_SECRET_NAME --value $HOSTNAME --output none