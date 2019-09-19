#!/bin/sh
while getopts :a:r:d: option
do
 case "${option}" in
 a) ACCOUNT_NAME=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 d) DB_NAME=${OPTARG};;
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
elif [ -z $DB_NAME ]; then
    echo "DB_NAME is empty"
    exit 1;
elif [ -z $THROUGHPUT ]; then
    echo "THROUGHPUT is empty"
    exit 1;
else
    echo "Input is valid"
fi

$DB="$(az cosmosdb database list --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --query "[?id=='$DB_NAME']" -o json | jq ".[].id")"
if [ -z $DB ]; then
    az cosmosdb database create --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --db-name $DB_NAME
    echo "created db $DB_NAME"
else
    echo "Db $DB_NAME already created"
fi