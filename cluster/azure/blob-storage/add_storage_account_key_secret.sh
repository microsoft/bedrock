#!/usr/bin/env bash

while getopts :g:a:v:n:s:c:d: option
do
    case "${option}" in
    g) RESOURCE_GROUP=${OPTARG};;
    a) STORAGE_ACCOUNT=${OPTARG};;
    b) SUBSCRIPTION_ID=${OPTARG};;
    v) VAULT_NAME=${OPTARG};;
    n) SECRET_NAME=${OPTARG};;
    c) VAULT_SUBSCRIPTION_ID=${OPTARG};;
    *) echo "ERROR: Please refer to usage guide on GitHub" >&2
        exit 1 ;;
    esac
done

if [ -z "$RESOURCE_GROUP" ]; then
    echo "usage: $0 -g <RESOURCE_GROUP>"
    exit 1
else
    echo "RESOURCE_GROUP=$RESOURCE_GROUP"
fi
if [ -z "$STORAGE_ACCOUNT" ]; then
    echo "usage: $0 -a <STORAGE_ACCOUNT>"
    exit 1
else
    echo "STORAGE_ACCOUNT=$STORAGE_ACCOUNT"
fi
if [ -z "$VAULT_NAME" ]; then
    echo "usage: $0 -v <VAULT_NAME>"
    exit 1
else
    echo "VAULT_NAME=$VAULT_NAME"
fi
if [ -z "$SECRET_NAME" ]; then
    echo "usage: $0 -n <SECRET_NAME>"
    exit 1
else
    echo "SECRET_NAME=$SECRET_NAME"
fi
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "usage: $0 -b <SUBSCRIPTION_ID>"
    exit 1
else
    echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
fi
if [ -z "$VAULT_SUBSCRIPTION_ID" ]; then
    echo "usage: $0 -c <VAULT_SUBSCRIPTION_ID>"
    exit 1
else
    echo "VAULT_SUBSCRIPTION_ID=$VAULT_SUBSCRIPTION_ID"
fi

echo "retrieving storage account"
keys="$(az storage account keys list --account-name $STORAGE_ACCOUNT --resource-group $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID)"
STORAGE_KEY=$(echo $keys | jq -r ".[0].value")

echo "add secret $SECRET_NAME to vault: $VAULT_NAME"
az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value $STORAGE_KEY --output none
