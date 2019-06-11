# Multiple AKS Clusters Deployment with Azure Traffic Manager

## Summary

The `azure-multiple-cluster-waf-tm-apimgmt` deploys 3 AKS clusters in 3 configurable regions, each of them behind an Application Gateway configured as a Web Application Firewall. A traffic manager that has is the front end to redirect traffic across the three regions.

The template also creates an API management service which is an enterprise grade API management service that provides several features such as throttling requests, managing dev subscriptions, header transformations and more. Visit the Microsoft docs [link](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts) for more details.

You can deploy the `azure-multiple-cluster-waf-tm-apimgmt` using a Service Principal that has Owner privileges on the Azure Subscription. 
To deploy this environment, follow the [common steps](https://github.com/microsoft/bedrock/blob/master/cluster/azure) for deploying a cluster with the following modifications:


# Getting Started

1. Copy [azure-multiple-clusters](../environments/azure-multiple-clusters) folder to a new sub directory
    ```
    $ cp -r cluster/environments/azure-multiple-clusters cluster/environments/<environment name>
    ```
2. Configure your clusters by updating following variables in `environments/azure/<environment name>/terraform.tfvars`:
* Terraform Azure Provider authentication configuration
    - `subscription_id`: Azure subscription id
    - `tenant_id`: Id of the Azure Active Directory Tenant associated with the subscription
* Application Gateway configuration
    - `Prefix`: prefix to be added in web application firewall name service.
    - `location`: Azure Region for web application firewall 
    - `resource_group_name_<region>`: Name of the resource group for the Web application firewall.
    - `vnet_<region>`: virtual network details for Web application firewall.
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
    - `service_principal_secret`: The secret of the service principal used by the AKS cluster. The creation of service principal described above in prerequisites section.
    - `service_principal_is_owner`: This value, set to "1" will deploy the clusters with the assumption that the Service Principal used for deploying the cluster has `Owner` level privileges.  If set to any other value, the deployment will not create the Azure Role Assignments and the Public IP Addresses will be deployed into the AKS node resource group. 
    - `ssh_public_key`: Contents of a SSH public key authorized to access the virtual machines within the cluster.
    - `gitops_ssh_url`: The git repo that contains the resource manifests that should be deployed in the cluster in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-manifests.git`). This repo must have a deployment key configured to accept changes from `gitops_ssh_key`.
    - `gitops_ssh_key`: Path to the *private key file* that was configured to work with the GitOps repository.
* West Cluster
    - `west_resource_group_name`: Name of the resource group for the cluster.
    - `west_resource_group_location`: Location of the Azure region. For ex: `westus2`.
    - `gitops_west_path`: Path to a subdirectory, or folder in a git repo
* Central cluster
    - `central_resource_group_name`: Name of the resource group for the cluster.
    - `central_resource_group_location`: Location of the Azure region. For ex: `centralus`.
    - `gitops_central_path`: Path to a subdirectory, or folder in a git repo
* East Cluster
    - `east_resource_group_name`:  Name of the resource group for the cluster.
    - `east_resource_group_locatio`: Location of the Azure region. For ex: `eastus2`.
    - `gitops_east_path`: Path to a subdirectory, or folder in a git repo
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
# Deploy the environment using Terraform
1. From the directory of the cluster you defined above (eg. `environments/azure/<environment name>`), run:

    ```
    > terraform init
    > terraform plan
    > terraform apply
    ```
2. Enter _yes_ when Terraform prompts with a plan that will be deployed in Azure subscription.
3. Make sure no errors.

# Configure `Kubectl` to connect to AKS clusters
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
# Verify clusters in the environment

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

If the Flux pod shows a status other than 'Running', verify Terraform deployed the environment without any errors in [step 2 above](#Step-2-Deploy-the-environment-using-Terraform).

