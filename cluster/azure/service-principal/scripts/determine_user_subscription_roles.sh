#!/usr/bin/env bash

# Check for dependencies
if ! jq -v > /dev/null
then
    echo "This script requires 'jq', please install it."
    exit 1
fi

# Retrieve account information
AZ_ACCOUNT_INFO=$(az account show)
AZ_CLI_USER=$(echo "$AZ_ACCOUNT_INFO" | jq -r '.user.name')
AZ_CLI_SUBSCRIPTION=$(echo "$AZ_ACCOUNT_INFO" | jq -r '.id')

# Retrieve role information for user on the subscription
ACCOUNT_SUBSCRIPTION_ROLES=$(az role assignment list --assignee "$AZ_CLI_USER" | jq -c ".[] | select( .scope == \"/subscriptions/$AZ_CLI_SUBSCRIPTION\" )" | jq -r '.roleDefinitionName')

echo "User roles for $AZ_CLI_USER on subscription $AZ_CLI_SUBSCRIPTION: "
for role in $ACCOUNT_SUBSCRIPTION_ROLES; do
    echo "    - $role"
    if [ "$role" == "Owner" ]; then
        isOwner=1
    fi
done

if [ "$isOwner" != "1" ]; then
    echo "$AZ_CLI_USER does not have Owner level privileges on subscription."
    echo "$AZ_CLI_USER will be unable to provision a service principal capable of doing deployments requiring role assignments."
else
    echo "$AZ_CLI_USER has Owner level privileges on subscription."
fi