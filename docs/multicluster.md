# Multicluster and Day 2 Infrastructure Scenarios

One of the central problems in any cloud deployment is managing the infrastructure that supports the workload. This task can be very difficult in many large organizations as they may have hundreds of workloads — but many fewer folks working in operations and reliability engineering roles to maintain that infrastructure.

The scale at which many of these organizations work also compounds this problem. Many of these workloads, for scale, latency, and/or reliability reasons, will span multiple clusters across multiple regions. These organizations need automation that enables them to leverage common deployment templates for all of these clusters to keep this complexity in check.

They also need the ability to manage configuration across all of these clusters: centralizing config where possible such that it can be updated in one place while still being able to have per cluster config where it isn’t.

If you followed our [single cluster infrastructure walkthrough](./singleKeyVault/README.md) you saw how Bedrock enables you to scaffold and generate Terraform deployment scripts. We will expand on that here to describe how Bedrock makes maintaining multiple Kubernetes clusters at scale easier.

Bedrock leverages Terraform for infrastructure deployment and the project itself maintains a number of base environment templates for common cluster deployment scenarios. These are just Terraform scripts and can be used directly (or even independently) from the rest of Bedrock’s automation.

What Bedrock’s infrastructure automation adds is the ability to maintain cluster deployments at scale by separating the definition of the deployment from the Terraform template used for that deployment such that our Terraform scripts are generated from these two components at deploy time.

This approach has a couple of advantages:

1. You can update the Terraform template in a central location and any of the downstream users of the template can take advantage of those improvements.
2. You can [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) out deployment definitions when multiple clusters are deployed with largely the same parameters — but still retain the ability to set per cluster config.

## Building a Multi-Cluster Definition

### Pre-reqs

- [Create Flux Manifest Respository](firstWorkload/README.md#create-and-configure-gitops-resource-manifest-repo)
- [Create Service Principal for each cluster](firstWorkload/README.md#create-an-azure-service-principal)
- Use [Deploying Common BedRock Infrastructure](single-cluster.md#deplying-the-common-infrastructure) to create two resource groups (`search-east-rg` and `search-west-rg`) and vnets (`search-east-vnet` and `search-east-vnet`) in both west and east locations (docs/single-cluster.md#deplying-the-common-infrastructure) which will be used below when filling in the east and west specific cluster information.

### Setting up common configuration for clusters

Let’s have a look at how this works in practice by building our first deployment definition for an application called `search` with two clusters in the `east` and `west` regions. We are going to use the Bedrock CLI to automate this — so [install Bedrock's prerequisites](../tools/prereqs) if you haven’t already.

We we are going to leverage the `azure-single-keyvault` template from the Bedrock project, which provides a template for a single cluster with Azure Keyvault for secrets management. We can scaffold out our infrastructure definition with this template with the following command:

```bash
$ bedrock infra scaffold --name search --source https://github.com/microsoft/bedrock --version 1.0 --template cluster/environments/azure-single-keyvault
```

This `scaffold` command creates a directory called `search` and creates a definition.yaml file in it that looks like this:

```yaml
name: search
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-single-keyvault
version: master
backend:
  storage_account_name: storage-account-name
  access_key: storage-account-access-key
  container_name: storage-account-container
  key: tfstate-key
variables:
  acr_enabled: 'true'
  address_space: <insert value>
  agent_vm_count: <insert value>
  agent_vm_size: <insert value>
  cluster_name: <insert value>
  dns_prefix: <insert value>
  flux_recreate: <insert value>
  gc_enabled: 'true'
  gitops_poll_interval: 5m
  gitops_label: flux-sync
  gitops_ssh_url: <insert value>
  gitops_url_branch: master
  gitops_ssh_key: <insert value>
  gitops_path: <insert value>
  keyvault_name: <insert value>
  keyvault_resource_group: <insert value>
  resource_group_name: <insert value>
  ssh_public_key: <insert value>
  service_principal_id: <insert value>
  service_principal_secret: <insert value>
  subnet_prefixes: <insert value>
  vnet_name: <insert value>
  subnet_name: <insert value>
  network_plugin: azure
  network_policy: azure
  oms_agent_enabled: 'false'
  enable_acr: 'false'
  acr_name: <insert value>
```

`scaffold` has downloaded the template locally, extracted all of the variables for the template, and provided defaults where possible for all of the variables.

We want to deploy multiple clusters and share common configuration values between them.  Given this, this particular definition, because it is the root definition for our workload as a whole across all of the clusters we are going to define, is where we are going to maintain those common values. So let's do that now:

```yaml
name: search
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-single-keyvault
version: master
backend:
  storage_account_name: "searchops"
  access_key: "7hDvyT4D2DNyD ... snip ... CiNvMEFYX1qTYHX3bT6XYva2tuN6Av+j+Kn259wQmA=="
  container_name: "tfstate"
variables:
  acr_enabled: true
  agent_vm_count: 6
  agent_vm_size: Standard_D8s_v3
  flux_recreate: false
  gc_enabled: true
  gitops_label: flux-sync
  gitops_poll_interval: 60s
  gitops_ssh_url: git@ssh.dev.azure.com:v3/fabrikam/search/resource-manifests
  gitops_url_branch: master
  gitops_ssh_key: "../../keys/gitops_repo_key" #make sure this points to your ssh keys generated for [access to gitops manifest repository](firstWorkload/README.md#generate-a-deploy-key-for-the-gitops-resource-manifest-repo)
  keyvault_name: "search-keyvault"
  keyvault_resource_group: "search-global-rg"
  ssh_public_key: "ssh-rsa AAAAB3Nza ... snip ... lgodNP7GExxNLSLqcsZa9ZALc+P3FRjgYbLC/qMWtkzPH5TEHPU4P5KLbHr4ZN3kV2MiARTtjWOlYMnMnrGu6NYxCmjHsbZxfhhZ2rU3uIEvjUBo9rdtQ== johndoe@fabrikam.com"
  service_principal_id: "something-3703-4842-8a96-9d8b1b7ea442"
  service_principal_secret: "a0927660-70f7-4306-8e0f-something"
  network_plugin: "azure"
  network_policy: "azure"
  oms_agent_enabled: "false"
  enable_acr: "true"
  acr_name: "fabrikam"
  subnet_prefix: "10.8.0.0/24"
```

### Setting up east cluster
With our common definition completed, let’s scaffold out our first physical cluster in the `east` region from within our `search-cluster` directory:

```bash
$ bedrock infra scaffold --name east --source https://github.com/microsoft/bedrock --version master --template cluster/environments/azure-single-keyvault
```

Scaffolding this cluster also creates a directory (called `east`) and a `definition.yaml` within it. When we go to generate a deployment from this, however, the tool will layer this hierarchy, taking the values from our common `definition.yaml` and then overlaying the values from our `east` definition on top. This is the mechanism that Bedrock uses to [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) out our deployment definitions, enabling you to define common variables in one place and have them inherited in each of the cluster definitions in directories underneath this central definition.

With this, let’s fill in the cluster definition with the variables specific to the `east` cluster:

```yaml
name: east
backend:
  key: "search-east"
variables:
  cluster_name: "search-east"
  dns_prefix: "search-east"
  gitops_path: "azure-search-east"
  resource_group_name: "search-east-rg"
  vnet_name: "search-east-vnet"
  subnet_name: "search-east-subnet"
```

Note that we didn’t include the `template` and `version` in the cluster `definition.yaml`.  This, and several of the common backend configuration variables, are also shared amongst the clusters.

### Setting up west cluster
With our `east` cluster defined let’s scaffold out our final cluster:

```bash
$ bedrock infra scaffold --name west --source https://github.com/microsoft/bedrock --version master --template cluster/environments/azure-single-keyvault
```

And fill the cluster definition for this with variable specific to the `west` cluster:

```yaml
name: west
backend:
  key: "search-west"
variables:
  cluster_name: "search-west"
  dns_prefix: "search-west"
  gitops_path: "azure-search-west"
  resource_group_name: "search-west-rg"
  vnet_name: "search-west-vnet"
  subnet_name: "search-west-subnet"
```

So with this, we have an overall definition for the `search` service across two clusters that looks like this:

```
.
└── search
    ├── definition.yaml
    ├── east
    │   └── definition.yaml
    ├── west
        └── definition.yaml
```

Again, when we go to generate the Terraform templates for the `west` cluster, it will first load the common `definition.yaml` at the root and overlay on top of them the values from `west/definition.yaml` definition.

## Generating Cluster Terraform Templates

We can now generate the Terraform scripts for deploying our `search ` clusters by executing this from our top level `search` directory:

```bash
$ bedrock infra generate --project east
$ bedrock infra generate --project west
```

This will generate the `search-generated/east` and `search-generated/west` cluster definitions, combining the per cluster config with the central common config, and generate the Terraform scripts for each of the clusters from on the base template that we specified such that our our directory structure now looks like this:

```
├── search
│   ├── definition.yaml
│   ├── east
│   │   └── definition.yaml
│   ├── bedrock.log
│   └── west
│       └── definition.yaml
├── search-generated
│   ├── east
│   │   ├── README.md
│   │   ├── acr.tf
│   │   ├── backend.tfvars
│   │   ├── main.tf
│   │   ├── bedrock.tfvars
│   │   └── variables.tf
│   └── west
│       ├── README.md
│       ├── acr.tf
│       ├── backend.tfvars
│       ├── main.tf
│       ├── bedrock.tfvars
│       └── variables.tf
```

## Deploying Cluster

With our clusters infrastructure templates created, we can now apply the templates.  Let’s start with the `east` cluster:

```bash
$ cd search-generated/east
$ terraform init -var-file=bedrock.tfvars -backend-config=./backend.tfvars
$ terraform plan -var-file=bedrock.tfvars
$ terraform apply -var-file=bedrock.tfvars
```

This deploys our `east` cluster.  We can naturally do the same thing for our `west` cluster with the same set of commands:

```bash

$ cd search-generated/west
$ terraform init -var-file=bedrock.tfvars -backend-config=./backend.tfvars
$ terraform plan -var-file=bedrock.tfvars
$ terraform apply -var-file=bedrock.tfvars
```

## Updating a Deployment Parameter

Naturally, change is a constant in any real world deployment, and typically we need a way to evolve clusters over time.  For example, and to make this discussion concrete, let’s say that our `search` workload has been wildly successful and that we want to expand the capacity of each of our clusters running it.

In the example above, we can do this by modifying the central `definition.yaml` to use a larger value for `agent_vm_count`, increasing the size from 6 to 8 nodes.

With this central change done, we can then regenerate the Terraform scripts for each of the clusters in the same manner that we did previously:

```bash
$ bedrock infra generate --project east
$ bedrock infra generate --project west
```

And then, cluster by cluster, plan and apply the templates:

```bash
$ cd east
$ terraform init --var-file=bedrock.tfvars -backend-config=./backend.tfvars
$ terraform plan --var-file=bedrock.tfvars
$ terraform apply --var-file=bedrock.tfvars
```

Since we are using backend state for these clusters to manage state, Terraform will examine the delta between the current and desired states and realize that there is an increase the size of the cluster from 6 to 8 nodes, and perform that adjustment operation on our cluster.

When our `east` cluster has been successfully upgraded in the same manner we can upgrade our `west` cluster to use 8 nodes.

## Upgrading Deployment Templates

One of the key tenets of Bedrock’s infrastructure automation is reducing the differences between clusters to as few as possible such that it is easier for folks in reliability engineering roles to reason about them at scale.

One way we enable that, as we mentioned previously, is to enable cluster deployments based off of a centrally managed template.  This enables downstream service teams to focus on their service and for upstream infrastructure teams to incrementally improve these templates and have them applied downstream.

If you were watching closely as we specified our `search` workload deployment, you might have noticed in our central deployment template that it specified a particular version of the deployment template:

```yaml
name: search
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-single-keyvault
version: master
...
```

This specifies that our deployment should use the `master` tag from the git repo specified in `source` such that our deployment template is not locked at a specific version. 

Version locking your deployment is important because you typically want to explicitly upgrade to new deployment templates versus have your deployment templates change underneath you while deploying an unrelated change as it would when specifying `master`.

Let’s say that your central infrastructure team has released the `1.1` version of this template and you want to stay at that version. We can upgrade our definition to that template by simply this version value:

```yaml
name: search
source: 'https://github.com/microsoft/bedrock'
template: cluster/environments/azure-single-keyvault
version: 1.1
...
```

And then regenerating (`bedrock infa generate --project west`) and applying the cluster definition in the same manner that we did above when we changed a [deployment parameter](#updating-a-deployment-parameter).

## Rotating / Updating a Service Principal

It is a common practice to rotate secrets.  The environments deployed by Bedrock rely upon a Service Principal for authentication and other operations. Depending upon how the Service Principal was created, either it or it's password may expire. If the Service Principal was to get compromised, that might be another reason that the Service Principal needs rotating.  The general approach when using the Azure CLI is discussed [here](https://docs.microsoft.com/en-us/azure/aks/update-credentials).  However, for Bedrock and the Terraform deployment, the process is straight forward.

First, per the [article](https://docs.microsoft.com/en-us/azure/aks/update-credentials) on updating credentials, create a new Service Principal (or password the existing Service Principal).  Next, update the section in your `definition.yaml`, specifically the following entries:

```yaml
  service_principal_id: "deadbeef-3703-4842-8a96-9d8b1b7ea442"
  service_principal_secret: "a0927660-70f7-4306-8e0f-deadbeef"
```

Then follow the steps for [updating a deployment parameter](#updating-a-deployment-parameter) above.

## Updating Cluster Node SSH Keys

When setting up the AKS cluster, one specifies the public component of an SSH key using the variable `ssh_public_key`.  This value is used to configure each of the nodes within the AKS cluster for SSH key authentication to log into the cluster nodes (using the private key).  Periodically, there will be a need to rotate these keys for security or other purposes.

Currently, there are two methods for updating the SSH keys:

- Update the `ssh_public_key` value and using Terraform
- Manually updating the keys using the Azure CLI

As of the writing of this document, each method has tradeoffs.

### Update SSH Key Using Terraform

Updating the SSH key using Terraform is not much different than updating other values like the Service Principal (above).  However, updating the SSH key using Terraform will result in the cluster being replaced by a new cluster rather than updating the current cluster in place.  To update the SSH key, one would modify your `tfvar` file by updating the `ssh_public_key`, say from:

```yaml
  ssh_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnpMloFHq5DO+w9UrdIKmVECSTlPAqSSmWCBshgFLfIcH93SCvR1mbYDqy2mIxj2Pzp2iUUPZNcI/YBWaX/Ck/hpLWGqYCnNRmWBaBoVPXozq0e0N2753mFFt95FZilExDG3q2kEP48Q8ZJJEMaRYRdEwu3hEXU4pIOeEWRsKDg+9OF8Tb4j3rA4tCLQVbBtlokkUfcTPFOpyWvG1GEE4r+sLwWUxQ2Nqh6ZHVUphVfOvK3Ub0Edkbx1oAa7hlJ5NrSqNmOnzBAr/WvOyLzFJ6DDURN8IvyikfjlQpPyYZv/lW5hDNeNy95JCW/dw0S+wMTUjX5/QKI1lP/kHnWMS7 jims@dooder"
```

to:

```yaml
  ssh_public_key="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC49yM9rOBzopU9eSMkxi9YxV9UueAqTXEmQzGuadxlMRbtPHVvES3TIq+TfG+EmKCOeWf1eoHEfD/XhbywXvkoLVWtx+OEiRaKMP9vQfqJ0cuUgoX23vdkUD+zX/GgPiwK/t6Bc0lWlpfaH3YEPhZbClC62vjHbDGcWNhmyIkFcWAs+COZtd+PG72XdmNjQ6Ob7Zb9a4PHhAH56qEZB+TrKJae8YsOuOrCcdxL8RnzF1IjBzkUmJUWJVBKXoES801oS4y2TmqPUqT4JRVOE6iOFITdj6raZ1h0ZTi79hSZcPj5s183dg87r2yOmRrOExUZdt0YVMxAH/szjMqTrcat jims@lostsierra"
```

One would then follow the steps for [updating a deployment parameter](#updating-a-deployment-parameter) above.

Again, this method will result in the cluster being replaced, rather than just updated.

### Manually Updating SSH Keys

The process to manually manage SSH keys in an AKS cluster can be found [here](https://docs.microsoft.com/en-us/azure/aks/ssh).  The process for setting or updating keys will depend on whether your AKS cluster is deployed as a VM Scale Set or or Availability Set.  In either case, the operations leverage the Azure CLI and modify the cluster in place, rather than replacing it.  It should be noted that this process will cause what is deployed to diverge from what the Terraform state is aware of.  So, while possible it is not recommended as subsequent updates to the AKS cluster that cause a "replacement" of the cluster instead of an "update" will over write the node keys with the one the Terraform state knows about.

## Updating the Flux SSH Key

Updating the Flux SSH key requires two steps.  First, the key must be added to the appropriate Azure DevOps or Github instance.  For Azure Devops, that process is outlined [here](https://github.com/microsoft/bedrock/tree/master/docs/firstWorkload#add-deploy-key-to-the-manifest-repository).  For Github, the process is described [here](https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account).  Once that process is done, the next step is to udated your `tfvar` file as follows:

```yaml
  gitops_ssh_key="/home/jims/.ssh/gitopskey"
```

to:

```yaml
  gitops_ssh_key="/home/jims/.ssh/gitopskey_new"
  flux_recreate=1
```

`flux_recreate` is necessary to force Terraform to redeploy Flux with the updated private key.  If `flux_recreate` is already set to `1`, change it to another value.  Once done, follow the steps for [updating a deployment parameter](#updating-a-deployment-parameter) above.

Unfortunately, at this time, the automation of adding an SSH key to Azure DevOps is a manual process that must be done through the portal.
