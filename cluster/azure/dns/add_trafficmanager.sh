#!/bin/bash
while getopts :s:g:z:t:e: option
do
    case "${option}" in
        s) SUBSCRIPTION_ID=${OPTARG};;
        g) RESOURCE_GROUP=${OPTARG};;
        z) DNS_ZONE_NAME=${OPTARG};;
        t) TRAFFIC_MANAGER_NAME=${OPTARG};;
        e) SERVICE_NAMES=${OPTARG};;
        *) echo "Please refer to usage guide on GitHub" >&2
            exit 1 ;;
    esac
done

if [ -z $RESOURCE_GROUP ]; then
    echo "RESOURCE_GROUP is empty"
    exit 1;
elif [ -z $DNS_ZONE_NAME ]; then
    echo "DNS_ZONE_NAME is empty"
    exit 1;
elif [ -z $TRAFFIC_MANAGER_NAME ]; then
    echo "TRAFFIC_MANAGER_NAME is empty"
    exit 1;
elif [ -z $SERVICE_NAMES ]; then
    echo "SERVICE_NAMES is empty"
    exit 1;
else
    echo "Input is valid"
fi


if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "use current subscription for dns"
else
    echo "switch to use subscription $SUBSCRIPTION_ID for dns"
    az account set -s $SUBSCRIPTION_ID
fi

TRAFFIC_MANAGER_FQDN="$TRAFFIC_MANAGER_NAME.trafficmanager.net"
SERVICE_NAME_ARRAY=($(echo "$SERVICE_NAMES" | tr ',' '\n'))
for SERVICE_NAME in "${SERVICE_NAME_ARRAY[@]}"
do
    echo "creating dns cname record $SERVICE_NAME"
    az network dns record-set cname create -g $RESOURCE_GROUP -z $DNS_ZONE_NAME -n $SERVICE_NAME --if-none-match

    echo "set dns cname record $SERVICE_NAME with value $TRAFFIC_MANAGER_FQDN"
    az network dns record-set cname set-record -g $RESOURCE_GROUP -z $DNS_ZONE_NAME -n $SERVICE_NAME -c $TRAFFIC_MANAGER_FQDN
done