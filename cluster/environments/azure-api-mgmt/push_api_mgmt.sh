#!/bin/sh
while getopts :f:g:k: option
do
 case "${option}" in
 f) rg_name=${OPTARG};;
 g) service_name=${OPTARG};;
 k) api_config_repo=${OPTARG};;
 esac
done


#
urlencode() {
  python -c 'import urllib, sys; print urllib.quote(sys.argv[1], sys.argv[2])' \
    "$1" "$urlencode_safe"
}

expire_time=$(date -d "+1 days" +%FT%TZ)


echo "api mgmt url: $api_config_repo"

# Obtain token bearer for 1 hour authentication access

token_out=$(curl -X POST \
-d "grant_type=client_credentials&client_id=$ARM_CLIENT_ID&client_secret=$ARM_CLIENT_SECRET&resource=https%3A%2F%2Fmanagement.azure.com%2F" \
https://login.microsoftonline.com/$ARM_TENANT_ID/oauth2/token)

echo $token_out

b_token=$(echo $token_out | jq '.access_token' --raw-output)

echo $b_token

# Enable git authentication
curl -i -H "Authorization: Bearer $b_token" https://management.azure.com/subscriptions/${ARM_SUBSCRIPTION_ID}/resourceGroups/${rg_name}/providers/Microsoft.ApiManagement/service/${service_name}/tenant/configuration/git?api-version=2018-06-01-preview

# Obtain Git token for repo access

response_out=$(curl -X \
    POST -d '{"api-version":"2018-06-01-preview", "keyType":"primary", "expiry": "'"$expire_time"'"}' \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $b_token" \
    https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$rg_name/providers/Microsoft.ApiManagement/service/$service_name/users/git/token?api-version=2018-06-01-preview)

# Encode token URL from value | be sure jq is installed
git_token=$(urlencode $(echo $response_out | jq '.value' --raw-output))

# Clone cofig repo and push policies in maintained repo to apim repo
git clone ${api_config_repo} apimpolicies
cd apimpolicies/

# Copy APIM configuration from maintained repo to APIM git repo
git remote add apim https://apim:$git_token@$service_name.scm.azure-api.net
git push -u apim

# Invoke repo in production
