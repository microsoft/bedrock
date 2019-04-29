# Azure Kubernetes Service Maintenance

During the lifecycle of a cluster, there may be need to perform maintenance activities.  If one were not using Bedrock, you might use the [Azure Portal](https://portal.azure.com) or the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) to do so.  Since Bedrock uses Terraform, most actions that would traditionally be used with the above tools need to be handled within the Terraform scripts that are part of Bedrock so Terraform can reflect the current state of the deployment accurately.

Typical update actions include:

- [Update Kubernetes Version](##update-kuberneted-version)

## Update Kubernetes Version

The process of and rules for updating the Kubernetes version in an AKS cluster, when using the Azure CLI is discussed [here](https://docs.microsoft.com/en-us/azure/aks/upgrade-cluster).  The rules regarding upgrading between versions applies both to the process of using the CLI as well if one deployed the AKS cluster via Terraform in Bedrock.

Bedrock uses the `kubernetes_version` to determine which version of Kubernetes is deployed.  The variable is defined within the module `azure/aks`, with the specific variable (and default version) [here](https://github.com/Microsoft/bedrock/blob/master/cluster/azure/aks/variables.tf#L36).

In order to update from version `1.12.6` to `1.12.7`, change the value of the linked variable.  Next, perform the relevant `terraform init`, `terraform apply` steps.