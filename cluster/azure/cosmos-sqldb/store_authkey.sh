#!/bin/sh
while getopts :a:r:v: option
do
 case "${option}" in
 a) ACCOUNT_NAME=${OPTARG};;
 r) RESOURCE_GROUP_NAME=${OPTARG};;
 v) VAULT_NAME=${OPTARG};;
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

SECRET_NAME="$ACCOUNT_NAME-authkey"
AUTH_KEY="$(az cosmosdb keys list --name $ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME -o json | jq ".primaryMasterKey")"

SECRET="$(az keyvault secret list --vault-name $VAULT_NAME --query "[?contains(id, '$SECRET_NAME')]" -o json | jq ".[].id")"
if [ -z $SECRET ]; then
    az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value $AUTH_KEY
    echo "authkey added to key vault"
else
    EXISTING_SECRET="$(az keyvault secret show --vault-name $VAULT_NAME --name "$SECRET_NAME" -o json | jq ".value")"
    if [ "$EXISTING_SECRET"=="$SECRET" ]; then
        az keyvault secret set --vault-name $VAULT_NAME --name $SECRET_NAME --value $AUTH_KEY
        echo "authkey added to key vault"
    else
        echo "authkey already added"
    fi
fi