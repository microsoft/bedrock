#!/usr/bin/env bash
set -euox pipefail

terraform workspace new $ENVIRONMENT || terraform workspace select $ENVIRONMENT
