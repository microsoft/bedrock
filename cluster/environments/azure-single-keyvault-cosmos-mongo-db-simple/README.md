# azure-single-keyvault-cosmos-mongo-db-simple

The `azure-single-keyvault-cosmos-mongo-db-simple` environment deploys a single production level AKS cluster configured with Flux and Azure Keyvault. Additionally, it will deploy a CosmosDB configured for MongoDB.

## Resource Group Requirement

The Azure Single Cluster environment requires the creation of a single resource group for cluster deployment, with the variable named `resource_group_name`.  In addition, there is a reference to the resource group created within [Azure Common Infra](../azure-common-infra).  To use the Azure CLI to create the resource group, see [here](../../azure/README.md).

## Getting Started

1. Copy this template directory to a repo of its own. Bedrock environments remotely reference the Terraform modules that they need and do not need be housed in the Bedrock repo.
2. Follow the instructions on the [main Azure page](../../azure#Deploying-Azure-Cluster) in this repo to create your cluster and surrounding infrastructure. This environment is dependant on a deployment on [azure-common-infra](../azure-common-infra), so configure and deploy azure-common-ifra prior to deploying `azure-single-keyvault-cosmos-mongo-db-simple`.

## Deploy the Environment

The `azure-single-keyvault-cosmos-mongo-db-simple` uses the `backend.tfvars` and requires that you create another .tfvars if it does not already exists (e.g. `terraform.tfvars`).

`backend.tfvars` (**NOTE**: you can and should use the same `backend.tfvars` that was used to deploy `azure-common-infra`, but with a different key as shown below):

```
storage_account_name="myStorageAccount"

access_key="<storage account access key>"

container_name="myContainer"

key="tfstate-single-keyvault-cosmos-mongo-db-simple"
```

If there is not a `terraform.tfvars`, create one that looks like this:

```

#--------------------------------------------------------------
# keyvault, vnet, and subnets are created seperately by azure-common-infra
#--------------------------------------------------------------
keyvault_name = "my-keyvault"
keyvault_resource_group = "my-global-rg"

address_space = "<cidr for cluster address space>"
subnet_prefixes = "10.39.0.0/16"
vnet_subnet_id = "/subscriptions/<subid>/resourceGroups/<my-global-rg>/providers/Microsoft.Network/virtualNetworks/<my-vnet>/subnets/<my-subnet>"


#--------------------------------------------------------------
# CosmosDB & MongoDB variables
#--------------------------------------------------------------

# resource_group_name = "" # Piggybacking off global rg for CosmosDB
cosmos_db_name = "my-cosmos-db-name"
mongo_db_name = "my-mongo-db-name"
# cosmos_db_offer_type = "Standard" - Optional field

#--------------------------------------------------------------
# Cluster variables
#--------------------------------------------------------------
agent_vm_count = "3"
agent_vm_size = "Standard_D4s_v3"

cluster_name = "azure-single-keyvault-cosmos-mongo-db-simple"
dns_prefix = "azure-single-keyvault-cosmos-mongo-db-simple"

gitops_ssh_url = "git@github.com:Microsoft/fabrikate-production-cluster-demo-materialized"
gitops_ssh_key_path = "./gitops_repo_key"

resource_group_name = "azure-single-keyvault-cosmos-mongo-db-simple-rg"
resource_group_location = "westus2"

ssh_public_key = "<ssh public key>"

service_principal_id = "<service principal id>"
service_principal_secret = "<service principal secret>"

#--------------------------------------------------------------
# Optional variables - Uncomment to use
#--------------------------------------------------------------
# gitops_url_branch = "release-123"
# gitops_poll_interval = "30s"
# gitops_path = "prod"
# gitops_label = "custom-flux-sync"

```

To deploy the `azure-single-keyvault-cosmos-mongo-db-simple` environment, run the following commands in your environment directory:

```
terraform init -backend-config=./backend.tfvars
terraform apply -var-file=./terraform.tfvars
```

## Configure kubectl to see your new AKS cluster

Upon deployment of the cluster, one artifact that the terraform scripts generate is the credentials necessary for logging into the AKS cluster that was deployed. These credentials are placed in the location specified by the variable "output_directory". For single cluster environments, this defaults to .”/output”.

With the default kube config file name, you can copy this to your ~/.kube/config by executing:

`$ KUBECONFIG=./output/bedrock_kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config`

It is also possible to use the config that was generated directly. For instance, to list all the pods within the flux namespace, run the following:

`$ KUBECONFIG=./output/bedrock_kube_config kubectl get po --namespace=flux`

## Verify that your AKS cluster is healthy

It is possible to verify the health of the AKS cluster deployment by looking at the status of the flux pods that were deployed. A standard deployment of flux creates two pods flux and flux-memcached. To check the status, enter the command:

```
kubectl get pods --namespace=flux
```

The pods should be deployed, and if in a healthy state, should be in a Running status. The output should resemble:

```
NAME                              READY   STATUS    RESTARTS   AGEflux-568b7ccbbc-qbnmv             1/1     Running   0          8m07sflux-memcached-59947476d9-d6kqw   1/1     Running   0          8m07s
```

If the Flux pod shows a status other than 'Running' (e.g. 'Restarting...'), it likely indicates that it is unable to connect to your GitOps repo. In this case, verify that you have assigned the correct public key to the GitOps repo (with write privileges) and that you have specified the matching private key in your Terraform configuration.
