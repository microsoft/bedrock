# azure-common-infra

The `azure-common-infra` environment is a production ready template to setup common permanent elements of your infrastructure like vnets, keyvault, and a common resource group for them. The `azure-common-infra` environment is a dependency environment for other environments like the `azure-single-keyvault`.

## Getting Started

1. Follow the instructions on the [main Azure page](../../azure) in this repo to create a [Service Principal](../../azure#create-an-azure-service-principal) and to [Configure Terraform CLI for Azure](../../azure#configure-terraform-cli-for-azure).
2. Copy this template directory to a repo of its own. Bedrock environments remotely reference the Terraform modules that they need and do not need be housed in the Bedrock repo:

    `cp -r cluster/environments/azure-common-infra cluster/environments/<your new cluster name>`

When this is complete, proceed with the following steps to complete the `azure-common-infra` deployment.

## Resource Group Requirement

This environment requires a single resource group be created.  The requisite variable is `resource_group_name`.  To use the Azure CLI to create the resource group, see [here](../../azure/README.md).

### Create Storage Account in Azure

Before attempting to deploy the infrastructure environments, you will also need to create an Azure Storage Account. You can do this in Azure Portal, or by using the Azure CLI:

```
az storage account create \
    --name mystorageaccount \
    --resource-group myResourceGroup \
    --location eastus \
    --sku Standard_LRS \
    --encryption blob
```

The Azure CLI needs your storage account credentials for most of the commands in this tutorial. While there are several options for doing so, one of the easiest ways to provide them is to set `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_KEY` environment variables.

First, display your storage account keys by using the az storage account keys list command:

```
az storage account keys list \
    --account-name myStorageAccount \
    --resource-group myResourceGroup \
    --output table
```

Now, set the `AZURE_STORAGE_ACCOUNT` and `AZURE_STORAGE_KEY` environment variables. You can do this in the Bash shell by using the export command:

```
export AZURE_STORAGE_ACCOUNT="mystorageaccountname"
export AZURE_STORAGE_KEY="myStorageAccountKey"
```

Blobs are always uploaded into a container. You can organize groups of blobs similar to the way you organize your files on your computer in folders.

Create a container for storing blobs with the az storage container create command.

`az storage container create --name mystoragecontainer`

### Deploy the Environment

The `azure-common-infra` environment should do the following in Azure using Terraform:

1. Create a resource group for your deployment
2. Create a VNET, and subnet(s)
3. Create an Azure Key Vault with the appropriate access policies

Edit the configuration values for `backend.tfvars`.The `backend.tfvars` should include the configuration for the Azure Storage Account that was created earlier. For example,

```
storage_account_name="myStorageAccount"

access_key="<storage account access key>"

container_name="myContainer"

key="tfstate-common-infra"
```

Create a `terraform.tfvars` if it does not already exist. It should include the following variables and look something like this:

```
vnet_name = "myvnet"

subnet_name = "mysubnet"

subnet_prefix = "10.39.0.0/24"

address_space = "10.39.0.0/16"

keyvault_name = "mykeyvault"

global_resource_group_name = "my-rg"

service_principal_id = "<appId"
```

Execute `terraform init -backend-config=./backend.tfvars`.

If `terraform init` succeeds, execute `terraform apply -var-file=./terraform.tfvars`.
