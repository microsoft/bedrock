# azure-common-infra

The `azure-common-infra` environment is a production ready template we provide to setup common permanent elements of your infrastructure like vnets, keyvault, and a common resource group for them.

## Getting Started

1. Copy this template directory to a repo of its own. Bedrock environments remotely reference the Terraform modules that they need and do not need be housed in the Bedrock repo.
2. Follow the instructions on the [main Azure page](../../azure) in this repo to create your cluster and surrounding infrastructure.