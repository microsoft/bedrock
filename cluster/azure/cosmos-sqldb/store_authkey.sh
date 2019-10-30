#!/bin/sh

set -e

while getopts :a:s:r:v:t: option
do
 case "${option}" in
 a) ACCOUNT_NAME=${OPTARG};;
 s) SUBSCRIPTION_ID=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 v) VAULT_NAME=${OPTARG};;
 t) VAULT_SUBSCRIPTION_ID=${OPTARG};;
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
elif [ -z $VAULT_NAME ]; then
    echo "VAULT_NAME is empty"
    exit 1;
else
    echo "Input is valid"
fi

if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "use current subscription for cosmosdb"
else
    echo "switch to use subscription $SUBSCRIPTION_ID for cosmosdb"
    az account set -s $SUBSCRIPTION_ID
fi

SECRET_NAME="$ACCOUNT_NAME-authkey"
AUTH_KEY=$(az cosmosdb keys list --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME -o json | jq ".primaryMasterKey")
AUTH_KEY=$(echo $AUTH_KEY | sed -e 's/^"//' -e 's/"$//') # it's base64-encoded, no need to wrap in quote

SECRET="$(az keyvault secret list --vault-name $VAULT_NAME --query "[?contains(id, '$SECRET_NAME')]" -o json | jq ".[].id")"

if [ -z "$VAULT_SUBSCRIPTION_ID" ]; then
    echo "use current subscription for keyvault"
else
    echo "switch to use subscription $VAULT_SUBSCRIPTION_ID for keyvault"
    az account set -s $VAULT_SUBSCRIPTION_ID
fi

if [ -z $SECRET ]; then
    az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value "$AUTH_KEY" --output none
    echo "authkey added to key vault"
else
    EXISTING_SECRET="$(az keyvault secret show --vault-name $VAULT_NAME --name "$SECRET_NAME" -o json | jq ".value")"
    if [ "$EXISTING_SECRET"=="$SECRET" ]; then
        az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value "$AUTH_KEY" --output none
        echo "authkey added to key vault"
    else
        echo "authkey already added"
    fi
fi