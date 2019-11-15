#!/bin/bash
while getopts :a:s:r:c: option
do
 case "${option}" in
 a) ACCOUNT_NAME=${OPTARG};;
 s) SUBSCRIPTION_ID=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 c) DB_COLLECTIONS=${OPTARG};;
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
elif [ -z $DB_COLLECTIONS ]; then
    echo "DB_COLLECTIONS is empty"
    exit 1;
else
    echo "Input is valid"
fi

json=

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "use current subscription for cosmosdb"
else
    echo "switch to use subscription $SUBSCRIPTION_ID for cosmosdb"
    az account set -s $SUBSCRIPTION_ID
fi

AUTH_KEY=$(az cosmosdb keys list --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME -o json | jq ".primaryMasterKey")
AUTH_KEY=$(echo $AUTH_KEY | sed -e 's/^"//' -e 's/"$//') # it's base64-encoded, no need to wrap in quote

echo "collections: \n$COLLECTIONS"

COLLECTION_ARRAY=($(echo "$COLLECTIONS" | tr '*' '\n'))
for i in "${COLLECTION_ARRAY[@]}"
do
    CURRENT_SETTINGS="$i"

    COLLECTION_SETTINGS=($(echo "$CURRENT_SETTINGS" | tr ',' '\n'))
    COLLECTION_NAME=${COLLECTION_SETTINGS[0]}
    PARTITION_KEY=${COLLECTION_SETTINGS[1]}
    THROUGH_PUT=${COLLECTION_SETTINGS[2]}
    echo "provisioning collection, name=$COLLECTION_NAME, partition=$PARTITION_KEY, throughput=$THROUGH_PUT"

    COLLECTION="$(az cosmosdb collection list --name $ACCOUNT_NAME --db-name $DB_NAME --resource-group $RESOURCE_GROUP_NAME --query "[?id=='$COLLECTION_NAME'].{id:id}" -o tsv)"
    if [ -z $COLLECTION ]; then
        echo "creating collection $COLLECTION_NAME without partition"
        if [ "$PARTITION_KEY" == "/_partitionKey" ]; then
            az cosmosdb collection create --name $ACCOUNT_NAME --db-name $DB_NAME --collection-name $COLLECTION_NAME --resource-group $RESOURCE_GROUP_NAME --throughput $THROUGH_PUT
        else
            echo "creating collection $COLLECTION_NAME with partition $PARTITION_KEY"
            az cosmosdb collection create --name $ACCOUNT_NAME --db-name $DB_NAME --collection-name $COLLECTION_NAME --resource-group $RESOURCE_GROUP_NAME --partition-key-path $PARTITION_KEY --throughput $THROUGH_PUT
        fi
        echo "created collection $COLLECTION_NAME"
    else
        echo "Collection $COLLECTION_NAME already created"
    fi
done