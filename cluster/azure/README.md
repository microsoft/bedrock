# Bedrock on Azure

## Summary

To get started with Bedrock on Azure, perform the following steps create an Azure Kubernetes Service (AKS) cluster using Terraform. 

- [Install required tools](#install-required-tools)
- [Set up GitOps repository for Flux](../common/flux/)
- [Azure Cluster Deployment](##Azure-Cluster-Deployment)

## Install required tools

As a first step, make sure you have installed the [pre-requisite tools](../README.md) on your machine.

Additionally, you need the Azure `az` command line tool in order to create and fetch Azure configuration info:

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Azure Cluster Deployment

Bedrock provides different templates to choose from for deployment.  Each template has a set of common
requirementts that must be met in order to deploy them.  Additionally, templates may have template 
specific requirements that need to be met.

The following templates are currently available for deployment:

- [azure-simple](../environments/azure-simple/): Single cluster deployment.
- [azure-multiple-clusters](../environments/azure-multiple-clusters/): Multiple clusters  deployment with Traffic Manager.
- [azure-advanced](../environments/azure-advanced): Single cluster deployment with Azure Keyvault integration through flex volumes.

The common steps necessary to deploy a cluster are:

- [Create an Azure service principal](#create-an-azure-service-principal)
- [Configure Terraform CLI to use the Azure Service Principal](#configure-terraform-cli-for-azure)
- [Create Terraform configuration files](#create-terraform-configuration-files)
- [Create the AKS cluster using Terraform](#create-the-aks-cluster-using-terraform)
- [Configure `kubectl` to see your new AKS cluster](configure-kubectl-to-see-your-new-aks-cluster)
- [Verify that your AKS cluster is healthy](verify-that-your-aks-cluster-is-healthy)

### Create an Azure Service Principal
You can generate an Azure Service Principal using the [`az ad sp create-for-rbac`](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create) command with `--skip-assignment` option. The `--skip-assignment` parameter limits any additional permissions from being assigned the default [`Contributor`](https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles#azure-rbac-roles) role in Azure subscription.

```bash
$ az ad sp create-for-rbac --subscription <id | name>
```

The output of the above commands are similar to the following example:

```bash
{
  "appId": "50d65587-abcd-4619-1234-f99fb2ac0987",
  "displayName": "azure-cli-2019-01-23-20-27-37",
  "name": "http://azure-cli-2019-01-23-20-27-37",
  "password": "3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

Note: You may receive an error if you do not have sufficient permissions on your Azure subscription to create a service principal.  If this happens, contact a subscription administrator to determine whether you have contributor-level access to the subscription.

There are some environments that that perform role assignments during the process of deployments.  In this case, the Service Principal requires Owner level access on the subscription.  Each environment where this is the case will document the requirements and whether or not there is a configuration option not requiring the Owner level privileges.

### Configure Terraform CLI for Azure

Terraform allows for a few [different ways to configure](https://www.terraform.io/docs/providers/azurerm/index.html) `terraform` to interact with Azure.  Bedrock is using the [Service Principal with Client Secret](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html) method specifically through the use of environment variables.

For *nxi based systems (Linux, Mac), one would set the variables as follows (using the values from the Service Principal created [above](#create-an-azure-service-principal)):

```bash
export ARM_SUBSCRIPTION_ID=7060ac3f-7a3c-44bd-b54c-4bb1e9cabcab
export ARM_CLIENT_ID=50d65587-abcd-4619-1234-f99fb2ac0987
export ARM_CLIENT_SECRET=3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11
export ARM_TENANT_ID=72f988bf-1234-abcd-91ab-2d7cd011db47
```

In order to determine the Subscription Id, one can use the Azure CLI as follows:

```bash
$ az account show
{
  "environmentName": "AzureCloud",
  "id": "7060ac3f-7a3c-44bd-b54c-4bb1e9cabcab",
  "isDefault": true,
  "name": "My Test Subscription",
  "state": "Enabled",
  "tenantId": "72f988bf-1234-abcd-91ab-2d7cd011db47",
  "user": {
    "name": "kermit@contoso.com",
    "type": "user"
  }
}
```

### Create Terraform Configuration Files

This is a two step process:

1. Create a new cluster configuration by copying an existing Terraform template
2. Customize your cluster by entering configuration values into '*.tfvars' files 

#### Clone Terraform Template

The typical way to create a new environment is to start from an existing template. To create a cluster environment based on the `azure-simple` template, copy it to a new subdirectory with the name of the cluster you want to create:

```bash
$ cp -r cluster/environments/azure-simple cluster/environments/<your new cluster name>
```

#### Edit Configuration Values

Most of the Bedrock deployment environments share a common set of configuration values.  Listed below are the common set of values and an explanation of what those values are.  In addition to these common values, environments that have additional variables, those are documented in the specific environments.

With the new environment created, edit `environments/azure/<your new cluster name>/terraform.tfvars` and update the variables as needed.

The common variables:

- `resource_group_name`: Name of the resource group where the cluster will be located.
- `resource_group_location`: Azure region the resource group should be created in.
- `cluster_name`: Name of the Kubernetes cluster you want to create.
- `agent_vm_count`: The number of agents VMs in the the node pool.
- `dns_prefix`: DNS name for accessing the cluster from the internet (up to 64 characters in length, alphanumeric characters and hyphen '-' allowed, and must start with a letter).
- `service_principal_id`: The id of the service principal used by the AKS cluster.  This is generated using the Azure CLI (see [Create an Azure service principal](#create-an-azure-service-principal) for details).
- `service_principal_secret`: The secret of the service principal used by the AKS cluster.  This is generated using the Azure CLI (see [Create an Azure service principal](#create-an-azure-service-principal) for details).
- `ssh_public_key`: Contents of a public key authorized to access the virtual machines within the cluster.  Copy the entire string contents of the gitops_repo_key.pub file that was generated in the [Set up GitOps repository for Flux](#set-up-gitops-repository-for-flux) step.
- `gitops_ssh_url`: The git repo that contains the resource manifests that should be deployed in the cluster in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-manifests.git`). This repo must have a deployment key configured to accept changes from `GitOps_ssh_key` (see [Set up GitOps repository for Flux](#set-up-gitops-repository-for-flux) for more details).
- `gitops_ssh_key`: Absolute path to the *private key file* (i.e. gitops_repo_key) that was generated in the [Set up GitOps repository for Flux](#set-up-gitops-repository-for-flux) step and configured to work with the GitOps repository.
-`gitops_path`: Path to a subdirectory, or folder in a git repo

The full list of variables that are customizable will be linked within each environment.

### Configure Terraform to Store State Data in Azure

Terraform records the information about what is created in a [Terraform state file](https://www.terraform.io/docs/state/) after it finishes applying.  By default, Terraform will create a file named `terraform.tfstate` in the directory where Terraform is applied.  Terraform needs this information so that it can be loaded when we need to know the state of the cluster for future modifications.

In production scenarios, storing the state file on a local file system is not desired because typically you want to share the state between operators of the system.  Instead, we configure Terraform to store state remotely, and in Bedrock we use Azure Blob Store for this storage.  This is defined using a `backend` block.  The basic block looks like:

```bash
terraform {
   backend “azure” {
   }
}
```

In order to setup an Azure backend, navigate to the [backend state](/azure/backend-state) directory and issue the following command:

```bash
> terraform apply -var 'name=<storage account name>' -var 'location=<storage account location>' -var 'resource_group_name=<storage account resource group>'
```

where `storage account name` is the name of the storage account to store the Terraform state, `storage account location` is the Azure region the storage account should be created in, and `storage account resource group` is the name of the resource group to create the storage account in.  

Once the storage account is created, we need to fetch storage account key so we can configure Terraform with it:

```bash
>  az storage account keys list --account-name <storage account name>
```

With this, update `backend.tfvars` file in your cluster environment directory with these values and use `terraform init -backend-config=./backend.tfvars` to setup usage of the Azure backend.