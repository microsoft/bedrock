#!/usr/bin/env bash
set -x

if ! jq --version > /dev/null
then
    echo "This script requires 'jq', please install it."
    exit 1
fi

while getopts :r:l: option
do
    case "${option}" in
    r) RESOURCE_GROUP=${OPTARG};;
    l) RESOURCE_GROUP_LOCATION=${OPTARG};;
    *) echo "ERROR: Please refer to usage guide on GitHub" >&2
        exit 1 ;;
    esac
done

if [ -z "$RESOURCE_GROUP" ] || [ -z "$RESOURCE_GROUP_LOCATION" ]; then
    echo "usage: $0 -r <resource group> -l <resource group location>"
    exit 1
fi

# create resource group and retrieve id
RESOURCE_GROUP_INFO=$(az group create -n "$RESOURCE_GROUP" -l "$RESOURCE_GROUP_LOCATION")
RESOURCE_GROUP_ID=$(echo "$RESOURCE_GROUP_INFO" | jq -r '.id')

# create service principal with contributor role on resource group
SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --role contributor --scopes "$RESOURCE_GROUP_ID")
echo "Service principal:"
echo "$SERVICE_PRINCIPAL"