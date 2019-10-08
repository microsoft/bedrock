#!/usr/bin/env bash

while getopts :i:a:v:n:s: option
do
    case "${option}" in
    i) INSTRUMENTATION_KEY=${OPTARG};;
    a) APP_ID=${OPTARG};;
    v) VAULT_NAME=${OPTARG};;
    n) INSTRUMENTATION_KEY_SECRET_NAME=${OPTARG};;
    s) APP_ID_SECRET_NAME=${OPTARG};;
    *) echo "ERROR: Please refer to usage guide on GitHub" >&2
        exit 1 ;;
    esac
done

if [ -z "$INSTRUMENTATION_KEY" ]; then
    echo "usage: $0 -n <INSTRUMENTATION_KEY>"
    exit 1
fi
if [ -z "$APP_ID" ]; then
    echo "usage: $0 -n <APP_ID>"
    exit 1
fi
if [ -z "$VAULT_NAME" ]; then
    echo "usage: $0 -v <VAULT_NAME>"
    exit 1
fi
if [ -z "$INSTRUMENTATION_KEY_SECRET_NAME" ]; then
    echo "usage: $0 -g <INSTRUMENTATION_KEY_SECRET_NAME>"
    exit 1
fi
if [ -z "$APP_ID_SECRET_NAME" ]; then
    echo "usage: $0 -g <APP_ID_SECRET_NAME>"
    exit 1
fi

az keyvault secret set --vault-name $VAULT_NAME --name $INSTRUMENTATION_KEY_SECRET_NAME --value $INSTRUMENTATION_KEY --output none
az keyvault secret set --vault-name $VAULT_NAME --name $APP_ID_SECRET_NAME --value $APP_ID --output none