#!/usr/bin/env bash
set -euo pipefail

az aks show -n $1 -g $2 --subscription $3 --query "{client_id:identity.principalId}"