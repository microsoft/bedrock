#!/usr/bin/env bash
set -euo pipefail

az aks show -n $1 -g $2 --subscription $3 --query "{kubelet_client_id:identityProfile.kubeletidentity.objectId,msi_client_id:identity.principalId,kubelet_id:identityProfile.kubeletidentity.resourceId,kubelet_resource_id:identityProfile.kubeletidentity.resourceId,node_resource_group:nodeResourceGroup}"