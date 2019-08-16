#!/usr/bin/env bash

while getopts :v:n:g:a:c:l: option
do
    case "${option}" in
    v) VAULT_NAME=${OPTARG};;
    n) IDENTITY_NAME=${OPTARG};;
    g) VAULT_RESOURCE_GROUP_NAME=${OPTARG};;
    a) AKS_CLUSTER_RESOURCE_GROUP=${OPTARG};;
    c) AKS_CLUSTER_NAME=${OPTARG};;
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

# AZ_ACCOUNT_INFO=$(az account show)
# AZ_CLI_SUBSCRIPTION=$(echo "$AZ_ACCOUNT_INFO" | jq -r '.id')

KEY_VAULT=$(az keyvault show -g "$VAULT_RESOURCE_GROUP_NAME" -n "$VAULT_NAME")
AZ_KEY_VAULT_ID=$(echo "$KEY_VAULT" | jq -r '.id')

# echo "Check if service principal "$SERVICE_PRINCIPAL_NAME" exist"
# EXISTING_SPNS=$(az ad sp list --display-name "$SERVICE_PRINCIPAL_NAME")
# EXISTING_SPN_FOUND=$(echo "$EXISTING_SPNS" | jq '. | length')

# if [ $EXISTING_SPN_FOUND -eq 0 ]; then
#     echo "Creating new service principal: $SERVICE_PRINCIPAL_NAME"
#     SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --name "$SERVICE_PRINCIPAL_NAME" --role "Reader" --scopes "$AZ_KEY_VAULT_ID")
#     echo "Service principal:"
#     echo "$SERVICE_PRINCIPAL"
# else
#     SPN_APP_ID=$(echo "$EXISTING_SPNS" | jq '[0].appId')
#     EXISTING_ASSIGNMENTS=$(az role assignment list --assignee $SPN_APP_ID --role Reader --scope "$AZ_KEY_VAULT_ID")
#     EXISTING_ASSIGNMENT_FOUND=$(echo "$EXISTING_ASSIGNMENTS" | jq '. | length')
#     if [ $EXISTING_ASSIGNMENT_FOUND -eq 0 ]; then
#         echo "Grant key vault reader role to service principal"
#         NEW_ASSIGNMENT=$(az role assignment create --assignee $SPN_APP_ID --role Reader --scope "$AZ_KEY_VAULT_ID")
#     else
#         echo "Key vault reader role to service principal is already granted"
#     fi
# fi

echo "Ensure msi $IDENTITY_NAME is created"
EXISTING_IDENTTIIES=$(az identity list --resource-group $AKS_CLUSTER_RESOURCE_GROUP --query "[?name=='$IDENTITY_NAME']" -o json)
EXISTING_IDENTITY_FOUND=$(echo "$EXISTING_IDENTTIIES" | jq '. | length')
MSI_ID=""
if [ $EXISTING_IDENTITY_FOUND -eq 0 ]; then
    $MSI_CREATED=$(az identity create -g $AKS_CLUSTER_RESOURCE_GROUP -n $IDENTITY_NAME)
    echo "Service identity:"
    echo "$MSI_CREATED"
    MSI_ID=$(echo "$MSI_CREATED" | jq '.clientId')
else
    MSI_ID=$(echo "$EXISTING_IDENTTIIES" | jq '.[0].clientId')
fi

echo "Ensure appropriate permissions are granted to msi"
UNDERSCORE="_"
AKS_NODE_RESOURCE_GROUP="MC$UNDERSCORE$AKS_CLUSTER_RESOURCE_GROUP$UNDERSCORE$AKS_CLUSTER_NAME$UNDERSCORE$AKS_CLUSTER_LOCATION"
AKS_NODE_RESOURCE_GROUP_ID=$(az group show -n $AKS_NODE_RESOURCE_GROUP | jq '.id')
az role assignment create --role "Reader" --assignee $MSI_ID --scope $AKS_NODE_RESOURCE_GROUP_ID

AKS_RESOURCE_GROUP_ID==$(az group show -n $AKS_CLUSTER_RESOURCE_GROUP | jq '.id')
az role assignment create --role "Reader" --assignee $MSI_ID --scope $AKS_RESOURCE_GROUP_ID

az role assignment create --role "Reader" --assignee $MSI_ID --scope $AZ_KEY_VAULT_ID

echo "Ensure Managed Identity Operator role is granted to aks spn"
EXISTING_AKS_SPNS=$(az ad sp list --display-name "$AKS_CLUSTER_NAME")
AKS_SPN_APP_ID=$(echo "$EXISTING_AKS_SPNS" | jq '.[0].appId')
az role assignment create --role "Managed Identity Operator" --assignee $AKS_SPN_APP_ID --scope $MSI_ID