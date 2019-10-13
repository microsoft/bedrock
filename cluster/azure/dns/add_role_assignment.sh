#!/bin/sh
while getopts :g:z:o: option
do
 case "${option}" in
 g) RESOURCE_GROUP=${OPTARG};;
 z) DNS_ZONE_NAME=${OPTARG};;
 o) SPN_OBJECT_ID=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

DNS_ZONE=$(az network dns zone show -g "$RESOURCE_GROUP" -n "$DNS_ZONE_NAME")
DNS_ZONE_ID=$(echo "$DNS_ZONE" | jq -r '.id' | sed -e 's/^"//' -e 's/"$//')
echo "dns zone id: $DNS_ZONE_ID"

EXISTING_ASSIGNMENTS=$(az role assignment list --role Contributor --assignee $SPN_OBJECT_ID --scope $DNS_ZONE_ID)
ASSIGNMENT_COUNT=$(echo "$EXISTING_ASSIGNMENTS" | jq ". | length")
if [ $ASSIGNMENT_COUNT -eq 0 ]; then
    az role assignment create --role Contributor --assignee $SPN_OBJECT_ID --scope $DNS_ZONE_ID
fi
