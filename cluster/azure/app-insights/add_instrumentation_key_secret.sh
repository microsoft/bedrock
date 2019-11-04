#!/usr/bin/env bash

while getopts :i:a:v:n:s:c:d:r:m: option
do
    case "${option}" in
    i) INSTRUMENTATION_KEY=${OPTARG};;
    a) APP_ID=${OPTARG};;
    v) VAULT_NAME=${OPTARG};;
    n) INSTRUMENTATION_KEY_SECRET_NAME=${OPTARG};;
    s) APP_ID_SECRET_NAME=${OPTARG};;
    c) CONTRIBUTORS=${OPTARG};;
    d) SUBSCRIPTION_ID=${OPTARG};;
    r) RESOURCE_GROUP=${OPTARG};;
    m) APP_INSIGHTS_NAME=${OPTARG};;
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
if [ -z "$CONTRIBUTORS" ]; then
    echo "usage: $0 -c <CONTRIBUTORS>"
    exit 1
fi
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "usage: $0 -d <SUBSCRIPTION_ID>"
    exit 1
fi
if [ -z "$RESOURCE_GROUP" ]; then
    echo "usage: $0 -r <RESOURCE_GROUP>"
    exit 1
fi
if [ -z "$APP_INSIGHTS_NAME" ]; then
    echo "usage: $0 -m <APP_INSIGHTS_NAME>"
    exit 1
fi

echo "add secret $INSTRUMENTATION_KEY_SECRET_NAME to vault: $VAULT_NAME"
az keyvault secret set --vault-name $VAULT_NAME --name $INSTRUMENTATION_KEY_SECRET_NAME --value $INSTRUMENTATION_KEY --output none
echo "add secret $APP_ID_SECRET_NAME to vault: $VAULT_NAME"
az keyvault secret set --vault-name $VAULT_NAME --name $APP_ID_SECRET_NAME --value $APP_ID --output none

SCOPE_ID="subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Insights/components/$APP_INSIGHTS_NAME"
echo "SCOPE_ID=$SCOPE_ID"

CONTRIBUTORS_ARRAY=($(echo "$CONTRIBUTORS" | tr ',' '\n'))
for contributor_object_id in "${CONTRIBUTORS_ARRAY[@]}"
do
    echo "contributor_object_id=$contributor_object_id"
    EXISTING_ASSIGNMENTS="$(az role assignment list --role Contributor --assignee $contributor_object_id --scope $SCOPE_ID -o json)"
    ASSIGNMENT_COUNT=$(echo "$EXISTING_ASSIGNMENTS" | jq ". | length")
    if [ $ASSIGNMENT_COUNT -eq 0 ]; then
        echo "add to app insights contributor"
        if ! $(az role assignment create --role Contributor --assignee-object-id $contributor_object_id --scope $SCOPE_ID); then
            echo "failed to set access control for app insights, bug: https://github.com/Azure/azure-cli/issues/11081"
        fi
    else
        echo "contributor is already set"
    fi
done