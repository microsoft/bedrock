#!/usr/bin/env bash
set -euox pipefail

terraform plan -var-file="${VAR_FILE_NAME}" -out "$PLAN_FILE"
