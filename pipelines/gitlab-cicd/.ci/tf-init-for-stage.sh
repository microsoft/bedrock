# #!/usr/bin/env bash
set -euox pipefail

terraform init -backend-config "storage_account_name=$AZURE_STORAGE_ACCOUNT_NAME" -backend-config "container_name=$AZURE_STORAGE_ACCOUNT_CONTAINER"
