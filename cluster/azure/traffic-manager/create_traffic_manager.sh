#!/bin/bash
while getopts :s:g:t:e:u:z:p option
do
    case "${option}" in
        s) SUBSCRIPTION_ID=${OPTARG};;
        g) RESOURCE_GROUP=${OPTARG};;
        t) TRAFFIC_MANAGER_NAME=${OPTARG};;
        e) SERVICE_NAMES=${OPTARG};;
        u) SERVICE_SUFFIX=${OPTARG};;
        z) DNS_ZONE_NAME=${OPTARG};;
        p) PROBE_PATH=${OPTARG};;
        *) echo "Please refer to usage guide on GitHub" >&2
            exit 1 ;;
    esac
done

if [ -z $RESOURCE_GROUP ]; then
    echo "RESOURCE_GROUP is empty"
    exit 1;
elif [ -z $TRAFFIC_MANAGER_NAME ]; then
    echo "TRAFFIC_MANAGER_NAME is empty"
    exit 1;
elif [ -z $SERVICE_NAMES ]; then
    echo "SERVICE_NAMES is empty"
    SERVICE_NAMES=""
elif [ -z $SERVICE_SUFFIX ]; then
    echo "SERVICE_SUFFIX is empty"
    SERVICE_SUFFIX=""
elif [ -z $DNS_ZONE_NAME ]; then
    echo "DNS_ZONE_NAME is empty"
    exit 1;
elif [ -z $PROBE_PATH ]; then
    echo "PROBE_PATH is empty"
    PROBE_PATH="/"
else
    echo "Input is valid"
fi

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "use current subscription for dns"
else
    echo "switch to use subscription $SUBSCRIPTION_ID for dns"
    az account set -s $SUBSCRIPTION_ID
fi

echo "ensure traffic-manager is created"
EXISTING="$(az network traffic-manager profile list -g $RESOURCE_GROUP --query "[?name=='$TRAFFIC_MANAGER_NAME']" -o json)"
FOUND=$(echo "$EXISTING" | jq '. | length')
if [ $FOUND -eq 0 ]; then
    echo "creating traffic manager $TRAFFIC_MANAGER_NAME"
    az network traffic-manager profile create -g $RESOURCE_GROUP -n $TRAFFIC_MANAGER_NAME \
        --routing-method Performance --unique-dns-name $TRAFFIC_MANAGER_NAME \
        --ttl 30 --protocol HTTPS --port 443 --path "$PROBE_PATH"
else
    echo "traffic manager $TRAFFIC_MANAGER_NAME is already created"
    az network traffic-manager profile create -g $RESOURCE_GROUP -n $TRAFFIC_MANAGER_NAME \
        --set monitorConfig.path="$PROBE_PATH"
fi

SERVICE_NAME_ARRAY=($(echo "$SERVICE_NAMES" | tr ',' '\n'))
for SERVICE_NAME in "${SERVICE_NAME_ARRAY[@]}"
do
    SERVICE_TARGET="$SERVICE_NAME$SERVICE_SUFFIX.$DNS_ZONE_NAME"
    SERVICE_HOST_NAME="$SERVICE_NAME.$DNS_ZONE_NAME"

    $EXISTING_ENDPOINTS="$(az network traffic-manager endpoint list -g $RESOURCE_GROUP --profile-name $TRAFFIC_MANAGER_NAME --query "[?name=='$SERVICE_NAME']" -o json)"
    ENDPOINT_FOUND=$(echo "$EXISTING" | jq '. | length')
    if [ $ENDPOINT_FOUND -eq 0 ]; then
        echo "creating traffic endpoint for $SERVICE_NAME targeting $SERVICE_TARGET with host $SERVICE_HOST_NAME"
        az network traffic-manager endpoint create -g $RESOURCE_GROUP --profile-name $TRAFFIC_MANAGER_NAME \
            -n $SERVICE_NAME --type externalEndpoints --endpoint-status enabled \
            --target $SERVICE_TARGET --custom-headers host=$SERVICE_HOST_NAME
    else
        echo "traffic endpoint for $SERVICE_NAME already exists"
        az network traffic-manager endpoint update --name $SERVICE_NAME --profile-name $TRAFFIC_MANAGER_NAME --resource-group $RESOURCE_GROUP \
            --target $SERVICE_TARGET --type externalEndpoints
    fi
done