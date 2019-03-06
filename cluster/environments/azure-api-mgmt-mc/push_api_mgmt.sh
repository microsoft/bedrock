#!/bin/sh
while getopts :b:f:g:k:d: option 
do 
 case "${option}" in 
 b) subscription_id=${OPTARG};;
 f) rg_name=${OPTARG};; 
 g) service_name=${OPTARG};; 
 k) api_config_repo=${OPTARG};; 
 d) authorization_bearer=${OPTARG};;
 esac
done 

KUBE_SECRET_NAME="flux-ssh"
RELEASE_NAME="flux"
KUBE_NAMESPACE="flux"
CLONE_DIR="flux"
REPO_DIR="$REPO_ROOT_DIR/$CLONE_DIR"
FLUX_CHART_DIR="chart/flux"
FLUX_MANIFESTS="manifests"

echo "api mgmt url: $REPO_ROOT_DIR"

rm -rf $REPO_ROOT_DIR

curl https://management.azure.com/subscriptions/${subscription_id}/resourceGroups/${rg_name}/providers/Microsoft.ApiManagement/service/${service_name}/tenant/configuration/git?api-version=2018-06-01-preview

# Get URL and Credentials for API Managements

# Create Tokens for git

# Git clone for from Repo

# Add contents into repo

# Git commit and push

# AZ delpoy to the Application Management Service