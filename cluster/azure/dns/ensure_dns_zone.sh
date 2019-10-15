#!/bin/sh
while getopts :g:z:c:o:e: option
do
 case "${option}" in
 g) RESOURCE_GROUP=${OPTARG};;
 z) DNS_ZONE_NAME=${OPTARG};;
 c) CAA_ISSUER_NAME=${OPTARG};;
 o) SPN_OBJECT_ID=${OPTARG};;
 e) ENV_NAME=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

echo "ensure dns zone is created"
EXISTING_ZONES=$(az network dns zone list -g "$RESOURCE_GROUP")
ZONE_COUNT=$(echo "$EXISTING_ZONES" | jq ". | length")
if [ $ZONE_COUNT -eq 0 ]; then
    az network dns zone create -g $RESOURCE_GROUP -n $DNS_ZONE_NAME
else
    echo "dns zone already created"
fi

if [ -z "$CAA_ISSUER_NAME" ]; then
    echo "ensure caa record to trust issuer"
    EXISTING_CAA_ISSUERS=$(az network dns record-set caa list -g "$RESOURCE_GROUP" -z "$DNS_ZONE_NAME")
    CAA_ISSUERS_COUNT=$(echo "$EXISTING_CAA_ISSUERS" | jq ". | length")
    if [ $CAA_ISSUERS_COUNT -eq 0 ]; then
        az network dns record-set caa add-record -g "$RESOURCE_GROUP" -z "$DNS_ZONE_NAME" -n "$ENV_NAME" --flags 0 --tag "issue" --value "$CAA_ISSUER_NAME"
    fi
fi

DNS_ZONE=$(az network dns zone show -g "$RESOURCE_GROUP" -n "$DNS_ZONE_NAME")
DNS_ZONE_ID=$(echo "$DNS_ZONE" | jq -r '.id' | sed -e 's/^"//' -e 's/"$//')
echo "dns zone id: $DNS_ZONE_ID"

echo "ensure spn has contributor access to dns zone"
EXISTING_ASSIGNMENTS=$(az role assignment list --role Contributor --assignee $SPN_OBJECT_ID --scope $DNS_ZONE_ID)
ASSIGNMENT_COUNT=$(echo "$EXISTING_ASSIGNMENTS" | jq ". | length")
if [ $ASSIGNMENT_COUNT -eq 0 ]; then
    az role assignment create --role Contributor --assignee-object-id $SPN_OBJECT_ID --scope $DNS_ZONE_ID
fi