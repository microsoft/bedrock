#!/bin/bash

# exit on error
set -e

# get cluster location
LOCATION="$1"

# call into Azure CLI to find default Kubernetes version for the given region
AKS_DEFAULT_VERSION=`az aks get-versions -l $LOCATION | jq -r '.orchestrators[] | select(.default == true) | .orchestratorVersion'`

# return the version as json
jq -n --arg ver "$AKS_DEFAULT_VERSION" '{"default_version":$ver}'
