#!/bin/sh
while getopts :a:r:c:l: option
do
 case "${option}" in
 a) ACCOUNT_NAME=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 c) CONSISTENCY=${OPTARG};;
 l) LOCATION=${OPTARG};;
  *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z $ACCOUNT_NAME ]; then
    echo "ACCOUNT_NAME is empty"
    exit 1;
elif [ -z $RESOURCE_GROUP_NAME ]; then
    echo "RESOURCE_GROUP_NAME is empty"
    exit 1;
elif [ -z $CONSISTENCY ]; then
    echo "CONSISTENCY is empty"
    exit 1;
else
    echo "Input is valid"
fi

ACCOUNT="$(az cosmosdb list --query "[?name=='$ACCOUNT_NAME']" -o json | jq ".[].id")"
if [ -z $ACCOUNT ]; then
    az cosmosdb create --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --default-consistency-level $CONSISTENCY --kind GlobalDocumentDB --locations "regionName=$LOCATION failoverPriority=0 isZoneRedundant=False"
    echo "created account $ACCOUNT_NAME"
else
    echo "Account $ACCOUNT_NAME already created"
fi