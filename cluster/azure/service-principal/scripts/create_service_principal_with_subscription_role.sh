#!/bin/bash
while getopts :r:s: option
do
    case "${option}" in
    r) ROLE=${OPTARG};;
    esac
done

if [ -z "$ROLE" ]; then
    echo "usage: $0 -r <role>"
    exit 1
fi

AZ_ACCOUNT_INFO=`az account show`
AZ_CLI_SUBSCRIPTION=`echo $AZ_ACCOUNT_INFO | jq -r '.id'`

SERVICE_PRINCIPAL=`az ad sp create-for-rbac --role $ROLE --scopes /subscriptions/$AZ_CLI_SUBSCRIPTION`
echo "Service principal:"
echo $SERVICE_PRINCIPAL