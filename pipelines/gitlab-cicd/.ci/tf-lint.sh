#!/usr/bin/env bash
set -euox pipefail

echo "Linting Terraform Files... If this fails, run 'terraform fmt -recursive' to fix"
terraform fmt -recursive -check
