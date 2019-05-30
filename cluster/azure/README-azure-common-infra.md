## Azure Common Infra

 Bedrock provides a variety of templates for creating AKS in Azure. This is a guide to deploy the `azure-common-infra` environment, which is a dependency environment for other environments like the [`azure-single-keyvault`](./README-azure-common-infra.md).

### Service Principals

You can generate an Azure Service Principal using the `az ad sp create-for-rbac` command with `--skip-assignment` option. The `--skip-assignment` parameter limits any additional permissions from being assigned the default Contributor role in Azure subscription.

`$ az ad sp create-for-rbac --subscription <id | name>`

The output of the above commands will look something like this:

```
{
"appId": "50d65587-abcd-4619-1234-f99fb2ac0987",  "displayName": "azure-cli-2019-01-23-20-27-37",
"name": "http://azure-cli-2019-01-23-20-27-37",  "password": "3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11",  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

**Note:** You may receive an error if you do not have sufficient permissions on your Azure subscription to create a service principal. If this happens, contact a subscription administrator to determine whether you have contributor-level access to the subscription.

There are some environments that that perform role assignments during the process of deployments. In this case, the Service Principal requires Owner level access on the subscription. Each environment where this is the case will document the requirements and whether or not there is a configuration option not requiring the Owner level privileges.

### Configure Terraform CLI for Azure

Terraform allows for a few different ways to configure terraform to interact with Azure. Bedrock is using the Service Principal with Client Secret method specifically through the use of environment variables.

For POSIX based systems (Linux, Mac), set the variables like this (using the values from the Service Principal created above):

```
export ARM_SUBSCRIPTION_ID=7060ac3f-7a3c-44bd-b54c-4bb1e9cabcab

export ARM_CLIENT_ID=50d65587-abcd-4619-1234-f99fb2ac0987

export ARM_CLIENT_SECRET=3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11

export ARM_TENANT_ID=72f988bf-1234-abcd-91ab-2d7cd011db47
```

You can use the Azure CLI to determine the subscription id:

```
$ az account show{  "environmentName": "AzureCloud",  "id": "7060ac3f-7a3c-44bd-b54c-4bb1e9cabcab",  "isDefault": true,  "name": "My Test Subscription",  "state": "Enabled",  "tenantId": "72f988bf-1234-abcd-91ab-2d7cd011db47",  "user": {    "name": "kermit@contoso.com",    "type": "user"  }}
```

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

### Deploying azure-common-infra Environment

The azure-common-infra environment comes as a dependency for the azure-single-keyvault environment, which is why it is the environment to deploy first. Before deploying this environment in Terraform, you will need to create a storage account in Azure. To do this:

This environment should do the following in Azure using Terraform:

1. Create a resource group for your deployment
2. Create a VNET, with subnet(s)
3. Create an Azure Key Vault with the appropriate access policies

To get started, create a new cluster configuration by copying an existing Terraform template. (if you have not already cloned the microsoft/Bedrock repository, you should do that first. You can do this by executing the following command:

`$ cp -r cluster/environments/azure-common-infra cluster/environments/<your new cluster name>`

Edit the configuration values for backend.tfvars.The backend.tfvars should include the configuration for the Azure Storage Account that was created earlier. For example,

```
storage_account_name="myStorageAccount"

access_key="gmnNFIa/LyKgbC7CZn9Io8jbngSW+Isa5vTZfKsIgkz/8EG2YPn4CV42hMDXmQ34zDu5Y7puFkAoWPHLtE6/mw=="

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

global_resource_group_location = "westus2"

service_principal_id = "dd6c3524-0f34-4b69-8c18-546e63a6a83f"

tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"
```

Execute `terraform init -backend-config=./backend.tfvars`.

If `terraform init` succeeds, execute `terraform apply -var-file=./terraform.tfvars`.
