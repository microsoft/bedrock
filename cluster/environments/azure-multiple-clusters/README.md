# Multiple AKS Clusters Deployment with Azure Traffic Manager

## Summary

This section describes how to deploy multiple AKS clusters by copying terraform scripts in this directory to a new directory.

This environment creates:

1. Deploys three AKS clusters in three different configurable Azure regions.
2. Creates three static public IP's to use in kubernetes loadbalancer service.
3. Creates a Azure Role Assignment for each AKS cluster Service Principal with `Network Contributor` role on each Public IP resource. 

    _The service principal used by the AKS cluster must have delegated permissions to the other resource group to modify network resources when kubernetes loadbalancer service is deployed. More information is available [here](https://docs.microsoft.com/en-us/azure/aks/static-ip#use-a-static-ip-address-outside-of-the-node-resource-group)._

3. Deploys Azure Traffic Manager profile with three different endpoint connecting to public IPs to route traffic based on a configured routing method.

## Prerequisites

### 1. Azure Authentication
You can authenticate to Azure with user account in Azure CLI (`az login`). If you are using a Service Principal for authentication, the client id and client secret needs to be [configured with Terrafrom Azure provider](https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html#configuring-the-service-principal-in-terraform).

---
**NOTE**

The Service Principal that is configured for authentication must have a Owner role in Azure Subscription. 

---

### 2. Service Principals
#### Authentication Service Principal
Create a Azure service principal for authentication with Azure subscription with the [`Owner`](https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles#azure-rbac-roles) role in the subscription with the following [`az ad sp create-for-rbac`](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create) command:

```bash
$ az ad sp create-for-rbac --role "Owner" --subscription <id | name>
```
#### AKS Cluster Service Principal
To allow an AKS cluster to interact with other Azure resources, an Azure Active Directory service principal is used. Create a service principal using the [`az ad sp create-for-rbac`](https://docs.microsoft.com/en-us/cli/azure/ad/sp?view=azure-cli-latest#az-ad-sp-create) command. The `--skip-assignment` parameter limits any additional permissions from being assigned the default [`Contributor`](https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles#azure-rbac-roles) role in Azure subscription.

```bash
$ az ad sp create-for-rbac --skip-assignment --subscription <id | name>
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
Make a note of the _appId_ and _password_. These values are used in the following steps.
## Deployment

### Step 1: Terraform Configuration

1. Copy [azure-multiple-clusters](../environments/azure-multiple-clusters) folder to a new sub directory
    ```
    $ cp -r cluster/environments/azure-multiple-clusters cluster/environments/<environment name>
    ```
2. Configure your clusters by updating following variables in `environments/azure/<environment name>/terraform.tfvars`:
* Terraform Azure Provider authentication configuration
    - `subscription_id`: Azure subscription id
    - `tenant_id`: Id of the Azure Active Directory Tenant associated with the subscription
    - `login_service_principal_id`: The appid of the service principal to authenticate and deploy the environment in Azure. The creation of service principal described above in [Service Principals](#Authentication-Service-Principal) section.
    - `login_service_principal_password`: The secret of the service principal used to authenticate with Azure.
* Traffic Manager configuration
    - `traffic_manager_profile_name`: Name of the Azure Traffic Manager Profile.
    - `traffic_manager_dns_name`: DNS name for accessing the traffic manager url from the internet. For ex: `http://<dnsname>.trafficmanager.net`.
    - `traffic_manager_resource_group_name`: Name of the resource group for the Traffic Manager.
    - `traffic_manager_resource_group_location`: Azure region the Traffic Manager resource group.
* Common configuration for all Kubernetes clusters
    - `cluster_name`: The name of the Kubernetes cluster. The location will be added as a suffix.
    - `agent_vm_count`: The number of agents VMs in the the node pool.
    - `dns_prefix`: DNS name for accessing the cluster from the internet.
    - `service_principal_id`: The id of the service principal used by the AKS cluster. The creation of service principal described above in [Service Principals](#AKS-Cluster-Service-Principal) section.
    - `service_principal_secret`: he secret of the service principal used by the AKS cluster. The creation of service principal described above in prerequisites section.
    - `ssh_public_key`: Contents of a SSH public key authorized to access the virtual machines within the cluster.
    - `gitops_ssh_url`: The git repo that contains the resource manifests that should be deployed in the cluster in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-manifests.git`). This repo must have a deployment key configured to accept changes from `gitops_ssh_key` (see [Set up GitOps repository for Flux](#set-up-gitops-repository-for-flux) for more details).
    - `gitops_ssh_key`: Path to the *private key file* that was configured to work with the GitOps repository.
* West Cluster
    - `west_resource_group_name`: Name of the resource group for the cluster.
    - `west_resource_group_location`: Location of the Azure region. For ex: `westus2`.
* Central cluster
    - `central_resource_group_name`: Name of the resource group for the cluster.
    - `central_resource_group_location`: Location of the Azure region. For ex: `centralus`.
* East Cluster
    - `east_resource_group_name`:  Name of the resource group for the cluster.
    - `east_resource_group_locatio`: Location of the Azure region. For ex: `eastus2`.
3. Configure Terraform backend. It is optional, but a best practice for production environment
* Navigate to the [backend state](/Azure/backend-state) directory and issue the following command. More information is avaialble in [Terraform docs](https://www.terraform.io/docs/backends/) and [Azure docs](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend).
    - `storage account name`: Name of the storage account to store the Terraform state.
    - `storage account location`: Location of the storage account.
    - `storage account resource group`: Name of the resource group to create the storage account in.

    ```bash
    > terraform apply -var 'name=<storage account name>' -var 'location=<storage account location>' -var 'resource_group_name=<storage account resource group>'
    ```
* Fetch storage account key to configure Terraform state:

    ```bash
    >  az storage account keys list --account-name <storage account name>
    ```

* Update `backend.tfvars` file in your cluster environment directory with these values and use  to setup usage of the Azure backend.
    ```bash
    > terraform init -backend-config=./backend.tfvars
    ````
### Step 2: Deploy the environment using Terraform
1. From the directory of the cluster you defined above (eg. `environments/azure/<environment name>`), run:

    ```
    > terraform init
    > terraform plan
    > terraform apply
    ```
2. Enter _yes_ when Terraform prompts with a plan that will be deployed in Azure subscription.
3. Make sure no errors.

### Step 3: Configure `Kubectl` to connect to AKS clusters
1. Each cluster credentials will be placed in the specified `output_directory` which defaults to `./output`. 
2. One kube config file will be created for each cluster with unique file name with `location` and `cluster-name` prefix that you can copy to your `~/.kube/config` directory or directly use the file in the shell.
* `location`: list of locations from the above configuration
    - `west_resource_group_location`
    - `central_resource_group_location`
    - `east_resource_group_locatio`
* `clustername`: cluster-name variable from the above configuration and a suffix
    - `cluster_name`-west
    - `cluster_name`-central
    - `cluster_name`-east
3. To copy, run the following command for each cluster after replacing `location` and `cluster-name`:
    ```bash
    $ KUBECONFIG=./output/<location>-<cluster-name>_kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config
    ```
4. To specify the file location directly to connect to any one of the cluster, replace the `location` and `cluster-name` in the following command and run:

    ```
    $ KUBECONFIG=./output/<location>-<clustername>_kube_config kubectl get po --namespace=flux` 
    ```
### Step 4: Verify clusters in the environment

1. Enter the following command to view the pods running in your cluster:

    ```bash
    kubectl get pods --n flux
    ```

2. You should see two Flux pods running (flux & flux-memcached). If your cluster is healthy and Flux is able to successfully connect to your GitOps repo, you will see something like this:

    ```bash
    NAME                              READY   STATUS    RESTARTS   AGE
    flux-568b7ccbbc-qbnmv             1/1     Running   0          8m07s
    flux-memcached-59947476d9-d6kqw   1/1     Running   0          8m07s
    ```

If the Flux pod shows a status other than 'Running', verify Terraform deployed the environment without any errors in [step 2 above](#Step-2:-Deploy-the-environment-using-Terraform).

#### You're done!

