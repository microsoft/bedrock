# Multiple AKS Clusters Deployment with Azure Traffic Manager

## Summary

The `azure-multiple-cluster-waf-tm-apimgmt` deploys 3 AKS clusters in 3 configurable regions, each of them behind an Application Gateway configured as a Web Application Firewall. A traffic manager as the front end to redirect traffic across the three regions.

The template also creates an API management service which is an enterprise grade service that provides several features to manage API access both within and outside an enterprise. Please visit the Microsoft docs [link](https://docs.microsoft.com/en-us/azure/api-management/api-management-key-concepts) for more details.

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
    - `vnet_<region>`: virtual network location for Web application firewall.

* Traffic Manager configuration
    - `traffic_manager_profile_name`: Name of the Azure Traffic Manager Profile.
    - `traffic_manager_dns_name`: DNS name for accessing the traffic manager url from the internet. For ex: `http://<dnsname>.trafficmanager.net`.
    - `traffic_manager_resource_group_name`: Name of the resource group for the Traffic Manager.
    - `traffic_manager_resource_group_location`: Azure region the Traffic Manager resource group.
* Common configuration for all Kubernetes clusters
    - `cluster_name`: The name of the Kubernetes cluster. The location will be added as a suffix.
    - `agent_vm_count`: The number of agents VMs in the the node pool.
    - `dns_prefix`: DNS name for accessing the cluster from the internet.
    - `service_principal_id`: The id of the service principal to be used by the AKS cluster. 
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
3. Configure Terraform backend. It is optional, but a best practice for production environments

* Navigate to the [backend state](/Azure/backend-state) directory and issue the following command. More information is available in [Terraform docs](https://www.terraform.io/docs/backends/) and [Azure docs](https://docs.microsoft.com/en-us/azure/terraform/terraform-backend).

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
3. Make sure there are no errors.

# Configure `Kubectl` to connect to AKS clusters
1. Each cluster's credentials will be placed in the specified `output_directory` which defaults to `./output`. 
2. One kube config file will be created for each of clusters with unique file name with `location` and `cluster-name` prefix that you can copy to your `~/.kube/config` directory or directly use the file in the shell.
* `location`: list of locations from the above configuration
    - `west_resource_group_location`
    - `central_resource_group_location`
    - `east_resource_group_location`
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

# azure-multiple-cluster-waf-tm-apimgmt

The `azure-multiple-cluster-waf-tm-apimgmt` environment deploys three redundant clusters (similar to that deployed with the `azure-single-keyvault` environment), each behind [Application Gateway](https://docs.microsoft.com/en-us/azure/application-gateway/overview). Application Gateway deployed on a specific cluster will get traffic via  [Azure Traffic Manager](https://azure.microsoft.com/en-us/services/traffic-manager/), which is configured with rules for routing traffic to one of the three Application gateways. On top of Traffic Manager  [API Management] (https://azure.microsoft.com/en-in/services/api-management/) is deployed, which is configured to manage and secure api. This act as point of communication for all request. 

## Getting Started

This deployment creates the following:

- [Three different AKS clusters](#cluster-deployment)
- [A Public IP Address](#public-ip-address) for each cluster
- [A Subnet in AKS Virtual network](#traffic-manager-deployment)
- [Azure Application Gateway](#application-gateway-deployment)
- [Azure Traffic Manager](#traffic-manager-deployment)
- [Azure API Managemenet](#API-management-deployment)
  
You can deploy the `azure-multiple-cluster-waf-tm-apimgmt` using a Service Principal that either has or does not have `Owner` privileges on the Azure Subscription using the variable `service_principal_is_owner`.  When set to `1`, `Owner` privileges are required and the Public IP for each AKS cluster will be deployed into the Resource Group specified for each of the clusters (see [Cluster Deployment](#cluster-deployment)).  When set to `0`, the Public IP for each AKS cluster will be provisioned in the Resource Group generated by the AKS Cluster Provisioner.  In this second case, `Owner` privileges are not required.  The reason for these options is based on allowing the AKS Cluster to make use of the Public IP, which is discussed [here](https://docs.microsoft.com/en-us/azure/aks/static-ip).  The default behavior is to deploy the cluster requiring `Owner` privileges.

To deploy this environment, follow the [common steps](../../azure/) for deploying a cluster with the following modifications:

- `resource_group` and `resource_group_location` are not used, as each component below references it's own Resource Group and Location
- `service_principal_is_owner` must be configured to `0` if the service principal doesn't have `Owner` permissions on the subscription
- Cluster specific configuration outlined in [Cluster Deployment](#cluster-deployment)
- Traffic Manager specific configuration outlined in [Traffic Manager Deployment](#traffic-manager-deployment)
- Application gateway specific configuration outlined in [Application Gateway Deployment](#application-gateway-deployment)
- API Management specific configuration outlined in [API Management Deployment](#API-management-deployment)

Additional environment-wide variables that can be configured are in [aks-variables.tf](./aks-variables.tf).

### Cluster Deployment

The `azure-multiple-cluster-waf-tm-apimgmt` environment assumes three regional clusters are deployed with their configurations and deployment scripts named accordingly - `aks-eastus`, `aks-westus`, `aks-centralus`.  If your region requirements differ, modify these names to match.

Each cluster (east, west, central) has three cluster-specific configuration variables:

- `<region>-resource_group_name`: The resource group name where the cluster will be deployed
- `<region>-resource_group_location`: The location of the resource group and where the cluster will be deployed
- `<region>-gitops-path`: This value is optional.  If configured, it should be configured for each of the three regions.  It specifies a path within the GitOps repo from which [Flux](../../common/flux) will pull manifests from.

Variables for each cluster can be found for [east](./aks-eastus-variables.tf), [west](./aks-westus-variables.tf), [central](./aks-centralus-variables.tf).

As part of cluster deployment, if you are deploying with `service_principal_is_owner=1`, in addition to creating the cluster, an Azure Role Assignment for each AKS cluster Service Principal will be created with `Network Contributor` role on the appropriate Public IP resource. 

As mentioned in [common steps](../../azure/), the deployment of an AKS cluster generates the corresponding Kubernetes Configuration file for that cluster and places it in the `output_directory`.  For the `azure-multiple-cluster-waf-tm-apimgmt` environment, the location where configuration files are written is the same, but each cluster has a cluster specific name for the output file, of the form `<cluster-resource-group-location>-<cluster-name>_kube_config` for each of the three unique Kubernetes configuration files corresponding to each cluster.

### Public IP Address

In order to route traffic through Traffic Manager to each AKS cluster, this template creates a Public IP Address resource for each cluster.  Depending on the configuration of `service_principal_is_owner`, the Public IP Address will either be provisioned in `<region>-resource-group-name` or within the Resource Group created by the Azure AKS Provider.

In addition to creating the Public IP Address for each cluster, a Traffic Manager Rule will be created for each Public IP Address so that the Traffic Manager knows about and can route traffic accordingly.


### Subnet Deployment

The Application Gateway requires it’s own subnet. In this subnet you can only deploy Application Gateways. As part of this deployment this subnet will be part of AKS VNet based on the Azure region. 

The configuration variables required for Subnet are:

- `resource_group_name_<region>`: Azure resource group name in which Vnet is hosted
- `vnet_<Region>`: The name of Vnet in which subnet will be created.

### Application Gateway

Azure Application Gateway acts as web traffic load balancer that enables us to manage traffic to the web applications.  In this implementation we had enabled a web application firewall (WAF) feature that provides centralized protection of web applications from common exploits and vulnerabilities. 

The configuration variables required for Application Gateway are:

- `Prefix`: prefix to be added in web application firewall name service.
- `location`: Azure Region for web application firewall 

### Traffic Manager Deployment

Azure Traffic Manager allows inbound traffic to be routed to one or more resources based upon a set of rules.  For this environment, the Traffic Manager is set up to route traffic to each of the deployed Application Gateway based off of the Public IP Address associated with each Application Gateway.

The configuration variables required for Traffic Manager are:

- `traffic_manager_profile_name`: The profile name (general name) of the Traffic Manager to be provisioned.
- `traffic_manager_dns_name`: External DNS name for the traffic manager.
- `traffic_manager_resource_group_name`: The name of the Resource Group Traffic Manager will be deployed to.
- `traffic_manager_resource_group_location`: The location where Traffic Manager will be deployed.


### API Management Deployment 

Azure API management provides turnkey solution for publishing APIs to external and internal customers.  For this environment, the API Management is set up to publish as API, which is internal calling traffic manager.

The configuration variables required for API Management are:

- `service_apim_name`: The profile name (general name) of the api management to be provisioned.

If the Flux pod shows a status other than 'Running', verify Terraform deployed the environment without any errors.

