# Azure Cluster Creation Guide

## Summary

Follow these steps to create an Azure Kubernetes Service (AKS) cluster using Terraform:

- [Install required tools](#install-required-tools)
- [Set up GitOps repository for Flux](../common/flux/)
- [Understand Service Principal Requirements](./service-principal)
- [Azure Cluster Deployment](#Azure-Cluster-Deployment)

For ongoing maintenance of an AKS cluster, take a look [here](./README-maintenance.md).

## Install required tools

Make sure you have installed the [common prerequisites](../README.md) on your machine.

Beyond these, you'll only need the Azure `az` command line tool installed (used to create and fetch Azure configuration info):

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Azure Cluster Deployment

Bedrock provides different templates to start from when building your deployment environment.  Each template has a set of common and specific requirements that must be met in order to deploy them.

Common across templates, it is required that the resource group(s) needed by the enviornment be created prior to deploying.  For how to create a resource group, see [here](#Creating-Resource-Groups).

The following templates are currently available for deployment:

- [azure-common-infra](../environments/azure-common-infra): Common infrastructure deployment template.
- [azure-simple](../environments/azure-simple/): Single cluster deployment.
- [azure-single-keyvault](../environments/azure-single-keyvault): Single cluster with Azure Keyvault integration through flex volumes template.
- [azure-multiple-clusters](../environments/azure-multiple-clusters/): Multiple cluster deployment with Traffic Manager.

### Deploying Azure Cluster
The common steps necessary to deploy a cluster are:

- [Build Fabrikate Definition for Container Deployment](../../docs/fabrikate/README.md)
- [Create an Azure service principal](#create-an-azure-service-principal)
- [Configure Terraform CLI to use the Azure Service Principal](#configure-terraform-cli-for-azure)
- [Create Terraform configuration files](#create-terraform-configuration-files)
- [Create the AKS cluster using Terraform](#create-the-aks-cluster-using-terraform)
- [Configure `kubectl` to see your new AKS cluster](#configure-kubectl-to-see-your-new-aks-cluster)
- [Verify that your AKS cluster is healthy](#verify-that-your-aks-cluster-is-healthy)

### Creating Resource Groups

Resource groups can be created throug the [Azure portal](https://portal.azure.com) or via the Azure CLI as follows:

```bash
$ az group create -n <resource group name> -l <resource group location>
```

Within each environment, the required resource groups that need to be created are documented.

### Create an Azure Service Principal

You can generate an Azure Service Principal using the [`az ad sp create-for-rbac`](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create) command with `--skip-assignment` option. The `--skip-assignment` parameter limits any additional permissions from being assigned the default [`Contributor`](https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles#azure-rbac-roles) role in Azure subscription.

```bash
$ az ad sp create-for-rbac --role contributor --scopes /subscriptions/<subscription id>/resourceGroups/<resource group>
```

The output of the above commands will look something like this:

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

There are some environments that perform role assignments during the process of deployments.  In this case, the Service Principal requires Owner level access on the subscription.  Each environment where this is the case will document the requirements and whether or not there is a configuration option not requiring the Owner level privileges.

### Assign Service Principal to Azure Container Registry (OPTIONAL)

If you are using an Azure Container Registry (ACR) you will want to make sure the service principal associated with your AKS cluster also has permissions to pull images. Run the following commands to grant a role assignment to your ACR.

```bash
RESOURCE_GROUP="<NAME OF YOUR RESOURCE GROUP>"
SERVICE_PRINCIPAL_ID="<APP ID OF SERVICE PRINCIPAL>"
ACR_NAME="<NAME OF YOUR ACR>"
# Obtain the full registry ID for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME -g $RESOURCE_GROUP --query id --output tsv)

# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
DESIRED_ROLE="<CHOOSE ROLE>"
ROLE_INFO=$(az role assignment create --assignee $SERVICE_PRINCIPAL_ID --scope $ACR_REGISTRY_ID --role $DESIRED_ROLE)
```

**Note**: If you will be using the same service principal to push images to your ACR in the build process you may want to choose `acr push` or `owner` as desired role.

### Configure Terraform CLI for Azure

Terraform allows for a few [different ways to configure](https://www.terraform.io/docs/providers/azurerm/index.html) `terraform` to interact with Azure.  Bedrock is using the [Service Principal with Client Secret](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html) method specifically through the use of environment variables.

For POSIX based systems (Linux, Mac), set the variables like this (using the values from the Service Principal created [above](#create-an-azure-service-principal)):

```bash
export ARM_SUBSCRIPTION_ID=7060ac3f-7a3c-44bd-b54c-4bb1e9cabcab
export ARM_CLIENT_ID=50d65587-abcd-4619-1234-f99fb2ac0987
export ARM_CLIENT_SECRET=3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11
export ARM_TENANT_ID=72f988bf-1234-abcd-91ab-2d7cd011db47
```

You can use the Azure CLI to determine the subscription id:

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

1. Create a new cluster configuration by copying an existing Terraform template.
2. Customize your cluster by entering configuration values into '*.tfvars' files.

#### Copy Terraform Template

The typical way to create a new environment is to start from an existing template. To create a cluster environment based on the `azure-simple` template, for example, copy it to a new subdirectory with the name of the cluster you want to create:

```bash
$ cp -r cluster/environments/azure-simple cluster/environments/<your new cluster name>
```

In this case, we are creating it within the Bedrock tree, but the deployment templates are designed to be relocatable to your own source tree instead as well.

#### Edit Configuration Values

Most Bedrock deployment environments share a common set of configuration values. Listed below are the common set of values and an explanation of those values. In addition to these common values, environments that have additional variables, check the `variables.tf` file for your template for specifics.

With the new environment created, edit `environments/azure/<your new cluster name>/terraform.tfvars` and update the variables as needed.

The common variables:

- `resource_group_name`: Name of the resource group where the cluster will be located.
- `resource_group_location`: Azure region the resource group should be created in.
- `cluster_name`: Name of the Kubernetes cluster you want to create.
- `agent_vm_count`: The number of agents VMs in the the node pool.
- `dns_prefix`: DNS name for accessing the cluster from the internet (up to 64 characters in length, alphanumeric characters and hyphen '-' allowed, and must start with a letter).
- `service_principal_id`: The id of the service principal used by the AKS cluster.  This is generated using the Azure CLI (see [Create an Azure service principal](#create-an-azure-service-principal) for details).
- `service_principal_secret`: The secret of the service principal used by the AKS cluster.  This is generated using the Azure CLI (see [Create an Azure service principal](#create-an-azure-service-principal) for details).
- `ssh_public_key`: Contents of a public key authorized to access the virtual machines within the cluster.  Copy the entire string contents of the gitops_repo_key.pub file that was generated in the [Set up GitOps repository for Flux](../common/flux/) step.
- `gitops_ssh_url`: The git repo that contains the resource manifests that should be deployed in the cluster in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-manifests.git`). This repo must have a deployment key configured to accept changes from `gitops_ssh_key_path` (see [Set up GitOps repository for Flux](../common/flux/) for more details).
- `gitops_ssh_key_path`: Absolute path to the *private key file* (i.e. gitops_repo_key) that was generated in the [Set up GitOps repository for Flux](../common/flux/) step and configured to work with the GitOps repository.
- `gitops_path`: Path to a subdirectory, or folder in a git repo
- `oms_agent_enabled`: Boolean variable that will provision OMS Linux agents to onboard Azure Monitor for containers. NOTE: `oms_agent_enabled` is set to false by default, but Azure Log Analytics resources (e.g. solutions, workspaces) will still be created, but not used.
- `vnet_name`: Name to an existing virtual network.

The full list of variables that are customizable are in the `variables.tf` file within each environment template.

Each component also may contain component specific variables that can be configured.  For instance, for the AKS module, additional configuration variables are found in [variables.tf](./aks/variables.tf).

### Create the AKS Cluster using Terraform

Bedrock requires a bash shell for the execution. Currently MacOSX, Ubuntu, and the Windows Subsystem for Linux (WSL) are supported.

From the directory of the cluster you defined above (eg. `environments/azure/<your new cluster name>`), run:
```
$ terraform init
```

This will download all of the modules needed for the deployment.

#### Importing existing resources
If you need to create the cluster within an existing resource group and Vnet/Subnet combo because for example this subnet is connected to your on premise network using VPN then you need to import these existing resources.

First add the required existing resources in ``main.tf`` in ``cluster/environments/<your new cluster name>/``

An example block might look like
```
resource "azurerm_resource_group" "existing_rg" {
 name = "My-Resource-Group"
 location = "${var.resource_group_location}"
 }

resource "azurerm_virtual_network" "existing_vnet" {
  name = "VNET"
  address_space = ["subnet address 1", "subnet address 1"]
  location = "${var.resource_group_location}"
  resource_group_name = "${azurerm_resource_group.existing_rg.name}"
  dns_servers = ["dns1", "dns2"]
}

resource "azurerm_subnet" "existing_subnet" {
 name = "subnet1"
 resource_group_name = "${azurerm_resource_group.existing_vnet.name}"
 virtual_network_name = "${azurerm_virtual_network.existing_vnet.name}"
 address_prefix = "subnet address 1"
}
```
Then you can use ``terraform import`` so that terraform knows about these resources and can maintain references to these in terraform state.

An example run might look like

```
terraform import azurerm_resource_group.existing_rg "/subscriptions/<<subscription_id>>/resourceGroups/My-Resource-Group"

terraform import azurerm_virtual_network.existing_vnet /subscriptions/<<subscription_id>>/resourceGroups/My-Resource-Group/providers/Microsoft.Network/virtualNetworks/VNET

terraform import azurerm_subnet.existing_subnet /subscriptions/<<subscription_id>>/resourceGroups/My-Resource-Group/providers/Microsoft.Network/virtualNetworks/VNET/subnets/subnet1
```
Be sure to replace the <<subscription_id>> with your own subscription id above.

You can then deploy the cluster with:

```
$ terraform apply
```
This will display the plan for what infrastructure Terraform plans to deploy into your subscription and ask for your confirmation.

Once you have confirmed the plan, Terraform will deploy the cluster, install [Flux](https://github.com/weaveworks/flux) in the cluster to kick off a [GitOps](https://www.weave.works/blog/GitOps-operations-by-pull-request) operator, and deploy any resource manifests in the `gitops_ssh_url`.

If errors occur during deployment, follow-on actions will depend on the nature of the error and at what stage it occurred.  If the error cannot be resolved in a way that enables the remaining resources to be deployed/installed, it is possible to re-attempt the entire cluster deployment.  First, from within the `environments/azure/<your new cluster name>` directory, run `terraform destroy`, then fix the error if applicable (necessary tool not installed, for example), and finally re-run `terraform apply`.

### Configure Terraform to Store State Data in Azure

Terraform records the information about what is created in a [Terraform state file](https://www.terraform.io/docs/state/) after it finishes applying.  By default, Terraform will create a file named `terraform.tfstate` in the directory where Terraform is applied.  Terraform needs this information so that it can be loaded when we need to know the state of the cluster for future modifications.

In production scenarios, storing the state file on a local file system is not desired because typically you want to share the state between operators of the system.  Instead, we configure Terraform to store state remotely, and in Bedrock, we use Azure Blob Store for this storage. This is defined using a `backend` block.  The basic block looks like:

```bash
terraform {
   backend "azurerm" {
   }
}
```

In order to setup an Azure backend, you need an Azure Storage account.  If you need to create one, navigate to the [backend state](backend-state) directory and issue the following command:

```bash
> terraform apply -var 'name=<storage account name>' -var 'location=<storage account location>' -var 'resource_group_name=<storage account resource group>'
```

where `storage account name` is the name of the storage account to store the Terraform state, `storage account location` is the Azure region the storage account should be created in, and `storage account resource group` is the name of the resource group to create the storage account in.

If there is already a pre-existing storage account, then retrieve the equivalent information for the existing account.

Once the storage account details are known, we need to fetch the storage account key so we can configure Terraform with it:

```bash
>  az storage account keys list --account-name <storage account name>
```

With this, update `backend.tfvars` file in your cluster environment directory with these values and use `terraform init -backend-config=./backend.tfvars` to setup using the Azure backend.

### Configure `kubectl` to see your new AKS cluster

Upon deployment of the cluster, one artifact that the `terraform` scripts generate is the credentials necessary for logging into the AKS cluster that was deployed.  These credentials are placed in the location specified by the variable `output_directory`.  For single cluster environments, this defaults to `./output`.

With the default kube config file name, you can copy this to your `~/.kube/config` by executing:

```bash
$ KUBECONFIG=./output/bedrock_kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config
```

It is also possible to use the config that was generated directly.  For instance, to list all the pods within the `flux` namespace, run the following:

```
$ KUBECONFIG=./output/bedrock_kube_config kubectl get po --namespace=flux`
```

__Note:__ To recreate/redownload credentials file from the cluster, simply delete the `bedrock_kube_config` file in the location specified by the variable `output_directory` and rerun `terraform apply`.

### Verify that your AKS cluster is healthy

It is possible to verify the health of the AKS cluster deployment by looking at the status of the `flux` pods that were deployed.  A standard deployment of `flux` creates two pods `flux` and `flux-memcached`.  To check the status, enter the command:

```bash
kubectl get pods --namespace=flux
```

The pods should be deployed, and if in a healthy state, should be in a `Running` status.  The output should resemble:

```bash
NAME                              READY   STATUS    RESTARTS   AGE
flux-568b7ccbbc-qbnmv             1/1     Running   0          8m07s
flux-memcached-59947476d9-d6kqw   1/1     Running   0          8m07s
```

If the Flux pod shows a status other than 'Running' (e.g. 'Restarting...'), it likely indicates that it is unable to connect to your GitOps repo. In this case, verify that you have assigned the correct public key to the GitOps repo (with write privileges) and that you have specified the matching private key in your Terraform configuration.
