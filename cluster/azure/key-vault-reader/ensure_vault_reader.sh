#!/usr/bin/env bash

while getopts :r:s: option
do
    case "${option}" in
    n) SERVICE_PRINCIPAL_NAME=${OPTARG};;
    v) VAULT_NAME=${OPTARG};;
    g) VAULT_RESOURCE_GROUP_NAME=${OPTARG};;
    *) echo "ERROR: Please refer to usage guide on GitHub" >&2
        exit 1 ;;
    esac
done

if [ -z "$SERVICE_PRINCIPAL_NAME" ]; then
    echo "usage: $0 -n <SERVICE_PRINCIPAL_NAME>"
    exit 1
fi
if [ -z "$VAULT_NAME" ]; then
    echo "usage: $0 -v <VAULT_NAME>"
    exit 1
fi
if [ -z "$VAULT_RESOURCE_GROUP_NAME" ]; then
    echo "usage: $0 -g <VAULT_RESOURCE_GROUP_NAME>"
    exit 1
fi

AZ_ACCOUNT_INFO=$(az account show)
AZ_CLI_SUBSCRIPTION=$(echo "$AZ_ACCOUNT_INFO" | jq -r '.id')

KEY_VAULT=$(az keyvault show -g "$VAULT_RESOURCE_GROUP_NAME" -n "$VAULT_NAME")
AZ_KEY_VAULT_ID=$(echo "$KEY_VAULT" | jq -r '.id')

echo "Check if service principal "$SERVICE_PRINCIPAL_NAME" exist"
EXISTING_SPNS=$(az ad sp list --display-name "$SERVICE_PRINCIPAL_NAME")
EXISTING_SPN_FOUND=$(echo "$EXISTING_SPNS" | jq '. | length')

if [ $EXISTING_SPN_FOUND -eq 0 ]; then
    echo "Creating new service principal: $SERVICE_PRINCIPAL_NAME"
    SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" --role "Reader" --scopes "$AZ_KEY_VAULT_ID")
    echo "Service principal:"
    echo "$SERVICE_PRINCIPAL"
else
    SPN_APP_ID=$(echo "$EXISTING_SPNS" | jq '[0].ID')
    EXISTING_ASSIGNMENTS=$(az role assignment list --assignee $SPN_APP_ID --role Reader --scope "$AZ_KEY_VAULT_ID")
    EXISTING_ASSIGNMENT_FOUND=$(echo "$EXISTING_ASSIGNMENTS" | jq '. | length')
    if [ $EXISTING_ASSIGNMENT_FOUND -eq 0 ]; then
        echo "Grant key vault reader role to service principal"
        NEW_ASSIGNMENT=$(az role assignment create --assignee $SPN_APP_ID --role Reader --scope "$AZ_KEY_VAULT_ID")
    else
        echo "Key vault reader role to service principal is already granted"
    fi
fi
