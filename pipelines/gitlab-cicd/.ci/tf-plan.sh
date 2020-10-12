#!/usr/bin/env bash
set -euox pipefail

# workaround for https://gitlab.com/gitlab-org/gitlab-foss/-/issues/65763
terraform plan -var-file="${!VAR_FILE_NAME}" -out "$PLAN_FILE"
