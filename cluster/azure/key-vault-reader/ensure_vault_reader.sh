#!/usr/bin/env bash

while getopts :v:n:g:a:c:l: option
do
    case "${option}" in
    v) VAULT_NAME=${OPTARG};;
    n) IDENTITY_NAME=${OPTARG};;
    g) VAULT_RESOURCE_GROUP_NAME=${OPTARG};;
    a) AKS_CLUSTER_RESOURCE_GROUP=${OPTARG};;
    c) AKS_CLUSTER_NAME=${OPTARG};;
    s) AKS_CLUSTER_SPN_NAME=${OPTARG};;
    l) AKS_CLUSTER_LOCATION=${OPTARG};;
    *) echo "ERROR: Please refer to usage guide on GitHub" >&2
        exit 1 ;;
    esac
done

if [ -z "$IDENTITY_NAME" ]; then
    echo "usage: $0 -n <IDENTITY_NAME>"
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

KEY_VAULT=$(az keyvault show -g "$VAULT_RESOURCE_GROUP_NAME" -n "$VAULT_NAME")
AZ_KEY_VAULT_ID=$(echo "$KEY_VAULT" | jq -r '.id')
echo "Key vault id: $AZ_KEY_VAULT_ID"

AKS_RESOURCE_GROUP_ID=$(az group show -n "$AKS_CLUSTER_RESOURCE_GROUP" | jq '.id')
echo "AKS resource group id: $AKS_RESOURCE_GROUP_ID"

UNDERSCORE="_"
AKS_NODE_RESOURCE_GROUP="MC$UNDERSCORE$AKS_CLUSTER_RESOURCE_GROUP$UNDERSCORE$AKS_CLUSTER_NAME$UNDERSCORE$AKS_CLUSTER_LOCATION"
AKS_NODE_RESOURCE_GROUP_ID=$(az group show -n "$AKS_NODE_RESOURCE_GROUP" | jq '.id')
echo "MC resource group id: $AKS_NODE_RESOURCE_GROUP_ID"

EXISTING_AKS_SPNS=$(az ad sp list --display-name "$AKS_CLUSTER_SPN_NAME")
AKS_SPN_APP_ID=$(echo "$EXISTING_AKS_SPNS" | jq '.[0].appId')
echo "AKS cluster spn app id: $AKS_SPN_APP_ID"

echo "Ensure msi $IDENTITY_NAME is created"
EXISTING_IDENTTIIES="$(az identity list --resource-group "$AKS_NODE_RESOURCE_GROUP" --query "[?name=='$IDENTITY_NAME']" -o json)"
EXISTING_IDENTITY_FOUND=$(echo "$EXISTING_IDENTTIIES" | jq '. | length')
MSI_CLIENT_ID=""
MSI_ID=""
if [ $EXISTING_IDENTITY_FOUND -eq 0 ]; then
    MSI_CREATED="$(az identity create -g "$AKS_NODE_RESOURCE_GROUP" -n "$IDENTITY_NAME" -o json)"
    echo "Service identity:"
    echo "$MSI_CREATED"
    MSI_CLIENT_ID=$(echo "$MSI_CREATED" | jq '.clientId')
    MSI_ID=$(echo "$MSI_CREATED" | jq '.id')
else
    MSI_CLIENT_ID=$(echo "$EXISTING_IDENTTIIES" | jq '.[0].clientId')
fi
echo "User-assigned identity client id: $MSI_CLIENT_ID"
echo "User-assigned identity id: $MSI_ID"

echo "Ensure appropriate permissions are granted to msi"
echo "az role assignment create --role \"Reader\" --assignee \"$MSI_CLIENT_ID\" --scope \"$AKS_NODE_RESOURCE_GROUP_ID\""
az role assignment create --role "Reader" --assignee "$MSI_CLIENT_ID" --scope "$AKS_NODE_RESOURCE_GROUP_ID"

echo "az role assignment create --role \"Reader\" --assignee \"$MSI_CLIENT_ID\" --scope \"$AKS_RESOURCE_GROUP_ID\""
az role assignment create --role "Reader" --assignee "$MSI_CLIENT_ID" --scope "$AKS_RESOURCE_GROUP_ID"

echo "az role assignment create --role \"Reader\" --assignee \"$MSI_CLIENT_ID\" --scope \"$AZ_KEY_VAULT_ID\""
az role assignment create --role "Reader" --assignee "$MSI_CLIENT_ID" --scope "$AZ_KEY_VAULT_ID"

echo "Ensure Managed Identity Operator role is granted to aks spn"
echo "az role assignment create --role \"Managed Identity Operator\" --assignee \"$AKS_SPN_APP_ID\" --scope \"$MSI_ID\""
az role assignment create --role "Managed Identity Operator" --assignee "$AKS_SPN_APP_ID" --scope "$MSI_ID"