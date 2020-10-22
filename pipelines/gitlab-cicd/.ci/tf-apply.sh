#!/usr/bin/env bash
set -euox pipefail

terraform apply -input=false -auto-approve $PLAN_FILE
