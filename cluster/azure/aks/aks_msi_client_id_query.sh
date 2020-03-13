#!/usr/bin/env bash
set -euo pipefail

az aks show -n $1 -g $2 --subscription $3 --query "{kubelet_client_id:identityProfile.kubeletidentity.clientId,msi_client_id:identity.objectId}"