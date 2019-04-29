# azure-multiple-cluster

The `azure-multiple-cluster` environment deploys three redundant clusters (similar to that deployed with the `azure-single-keyvault` environment), each behind [Azure Traffic Manager](https://azure.microsoft.com/en-us/services/traffic-manager/), which is configured with rules for routing traffic to one of the three clusters.

`azure-multiple-cluster` is dependant on a deployment of [`azure-common-infra`](../azure-common-infra).

## Getting Started

This deployment creates the following:

- [azure-multiple-cluster](#azure-multiple-cluster)
  - [Getting Started](#getting-started)
    - [Cluster Deployment](#cluster-deployment)
    - [Public IP Address](#public-ip-address)
    - [Traffic Manager Deployment](#traffic-manager-deployment)

You can deploy the `azure-multiple-cluster` using a Service Principal that has `Owner` privileges on the Azure Subscription. The Public IP for each AKS cluster will be deployed to the appropriate, non-derived resource group. 

To deploy this environment, follow the [common steps](../../azure/) for deploying a cluster with the following modifications:

- `resource_group` and `resource_group_location` are not used, as each component below references it's own Resource Group and Location
- Cluster specific configuration outlined in [Cluster Deployment](#cluster-deployment)
- Traffic Manager specific configuration outlined in [Traffic Manager Deployment](#traffic-manager-deployment)

Additional environment-wide variables that can be configured are in [aks-variables.tf](./aks-variables.tf).

### Cluster Deployment

The `azure-multiple-cluster` environment assumes three regional clusters are deployed with their configurations and deployment scripts named accordingly - `aks-eastus`, `aks-westus`, `aks-centralus`.  If your region requirements differ, modify these names to match.

Each cluster (east, west, central) has three cluster-specific configuration variables:

- `<region>-resource_group_name`: The resource group name where the cluster will be deployed
- `<region>-resource_group_location`: The location of the resource group and where the cluster will be deployed
- `<region>-gitops-path`: This value is optional.  If configured, it should be configured for each of the three regions.  It specifies a path within the GitOps repo from which [Flux](../../common/flux) will pull manifests from.

Variables for each cluster can be found for [east](./aks-eastus-variables.tf), [west](./aks-westus-variables.tf), [central](./aks-centralus-variables.tf).

As part of cluster deployment, if you are deploying with `service_principal_is_owner=1`, in addition to creating the cluster, an Azure Role Assignment for each AKS cluster Service Principal will be created with `Network Contributor` role on the appropriate Public IP resource. 

As mentioned in [common steps](../../azure/), the deployment of an AKS cluster generates the corresponding Kubernetes Configuration file for that cluster and places it in the `output_directory`.  For the `azure-multiple-cluster` environment, the location where configuration files are written is the same, but each cluster has a cluster specific name for the output file, of the form `<cluster-resource-group-location>-<cluster-name>_kube_config` for each of the three unique Kubernetes configuration files corresponding to each cluster.

### Public IP Address

In order to route traffic through Traffic Manager to each AKS cluster, this template creates a Public IP Address resource for each cluster. The Public IP Address will be provisioned within the Resource Group created by the Azure AKS Provider.

In addition to creating the Public IP Address for each cluster, a Traffic Manager Rule will be created for each Public IP Address so that the Traffic Manager knows about and can route traffic accordingly.

### Traffic Manager Deployment

Azure Traffic Manager allows inbound traffic to be routed to one or more resources based upon a set of rules.  For this environment, the Traffic Manager is set up to route traffic to each of the deployed AKS Clusters based off of the Public IP Address associated with each cluster.

The configuration variables required for Traffic Manager are:

- `traffic_manager_profile_name`: The profile name (general name) of the Traffic Manager to be provisioned.
- `traffic_manager_dns_name`: External DNS name for the traffic manager.
- `traffic_manager_resource_group_name`: The name of the Resource Group Traffic Manager will be deployed to.
- `traffic_manager_resource_group_location`: The location where Traffic Manager will be deployed.
