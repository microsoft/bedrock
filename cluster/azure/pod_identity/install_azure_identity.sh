#!/bin/bash

# parse command-line arguments
while getopts :g:s:c:i: option 
do 
 case "${option}" in 
 g) RESOURCE_GROUP=${OPTARG};;
 s) SUBSCRIPTION_ID=${OPTARG};;
 c) IDENTITY_CLIEND_ID=${OPTARG};;
 i) IDENTITY_NAME=${OPTARG};;
 *) echo "ERROR: Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done 

# Deploy Azure Identity
read -r -d '' AZURE_IDENTITY_YAML << EOM
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: $IDENTITY_NAME
spec:
  type: 0
  ResourceID: /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP/providers/Microsoft.ManagedIdentity/userAssignedIdentities/$IDENTITY_NAME
  ClientID: $IDENTITY_CLIEND_ID
EOM

# Deploy Azure Identity into the cluser
if ! echo "$AZURE_IDENTITY_YAML" | kubectl create -f -
then
    echo "Unable to deploy azure identity into cluster."
    exit 1
fi

# Deploy Azure Identity Binding
read -r -d '' AZURE_IDENTITY_BINDING_YAML << EOM
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: $IDENTITY_NAME-identity-binding
spec:
  AzureIdentity: $IDENTITY_NAME
  Selector: $IDENTITY_NAME_msi_selector
EOM

# Deploy Azure Identity Binding into the cluser
if ! echo "$AZURE_IDENTITY_BINDING_YAML" | kubectl create -f -
then
    echo "Unable to deploy azure identity binding into cluster."
    exit 1
fi