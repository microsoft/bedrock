# Bedrock Tools

This directory contains tools for working with both the release process as well as helping to facilitate pull requests, especially when remote references to modules need to be updated.

Currently, the scripts are:

- `bedrock_terraform_release.sh` - this script updates remote references and creates a branch for which releases can be generated
- `toggle_remote_ref.sh` - this script is used to toggle remote references in your repository so when a PR is issued with changes affecting remote modules, those changes (in the branch the PR is based on) can be toggled easily for testing (and then returned to reference master post testing)