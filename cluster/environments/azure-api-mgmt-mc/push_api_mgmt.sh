#!/bin/sh
while getopts :b:f:g:k:d: option 
do 
 case "${option}" in 
 b) subscription_id=${OPTARG};;
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

b_token=$(echo $token_out | jq '.access_token' --raw-output)

# Enable git authentication
curl -i -H "Authorization: Bearer $b_token" https://management.azure.com/subscriptions/7060bca0-7a3c-44bd-b54c-4bb1e9facfac/resourceGroups/myapimgmt-rg/providers/Microsoft.ApiManagement/service/indiahack/tenant/access/?api-version=2018-06-01-preview
curl -i -H "Authorization: Bearer $b_token" https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${rg_name}/providers/Microsoft.ApiManagement/service/${service_name}/tenant/configuration/git?api-version=2018-06-01-preview

# Obtain Git token for repo access

response_out=$(curl -X \
    POST -d '{"api-version":"2018-06-01-preview", "keyType":"primary", "expiry": "'"$expire_time"'"}' \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $b_token" \
    https://management.azure.com/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$rg_name/providers/Microsoft.ApiManagement/service/$service_name/users/git/token?api-version=2018-06-01-preview)

# Encode token URL from value | be sure jq is installed
git_token=$(urlencode $(echo $response_out | jq '.value' --raw-output))

# Clone cofig repo and push policies in maintained repo to apim repo
git clone ${api-config-repo} apimpolicies
cd apimpolicies/

# Copy APIM configuration from maintained repo to APIM git repo
git remote add apim https://apim:$git_token@$service_name.scm.azure-api.net
git push -u apim

# Invoke repo in production