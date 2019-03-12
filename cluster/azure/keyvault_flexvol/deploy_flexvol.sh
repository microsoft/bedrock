#!/bin/sh

# parse command-line arguments
while getopts :i:p:s:r:k: option 
do 
 case "${option}" in 
 i) SERVICE_PRINCIPAL_ID=${OPTARG};;
 p) SERVICE_PRINCIPAL_SECRET=${OPTARG};; 
 s) SUBSCRIPTION_ID=${OPTARG};;
 r) RESOURCE_GROUP=${OPTARG};;
 k) KEYVAULT_NAME=${OPTARG};;
 esac
done 

# Assign Reader Role to the service principal for your keyvault
echo "Adding reader role on KeyVault for service principal"
az role assignment create --role Reader --assignee $SERVICE_PRINCIPAL_ID --scope /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME
if [ $? -ne 0 ]; then
    echo "Unable to grant Reader Role.  Ensure the service principal being used to deploy the cluser has Ownership privileges."
    exit 1
fi

# Give service principal permissions to the keyvault
echo "Adding permissions to retrieve keys for service principal"
az keyvault set-policy -n $KEYVAULT_NAME --key-permissions get --spn $SERVICE_PRINCIPAL_ID 
if [ $? -ne 0 ]; then
    echo "Unable to set key permissions"
    exit 1
fi

echo "Adding permissions to retrieve secrets for service principal"
az keyvault set-policy -n $KEYVAULT_NAME --secret-permissions get --spn $SERVICE_PRINCIPAL_ID 
if [ $? -ne 0 ]; then
    echo "Unable to set secret permissions"
    exit 1
fi

echo "Adding permissions to retrieve certificates for service principal"
az keyvault set-policy -n $KEYVAULT_NAME --certificate-permissions get --spn $SERVICE_PRINCIPAL_ID 
if [ $? -ne 0 ]; then
    echo "Unable to set retrieve permissions"
    exit 1
fi

echo "Adding service principal into KeyVault as a secret"
    kubectl create secret generic kvcreds --from-literal clientid=$SERVICE_PRINCIPAL_ID --from-literal clientsecret=$SERVICE_PRINCIPAL_SECRET --type=azure/kv

