# Cluster Deployment

Bedrock automates Kubernetes cluster deployments with Terraform so that they can be reproducably built to make cluster operations more predictable than ad hoc or shell script based approaches.  This automation currently only has support for the Azure cloud, but we would welcome pull requests for other public clouds.

## Setup

Bedrock uses three tools to automate cluster deployments. Take a moment to install these if you don't have any of them:

- [terraform](https://www.terraform.io/intro/getting-started/install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Bedrock uses [Helm](https://github.com/helm/helm) to setup the cluster. If you haven't already, install it:

- [helm](https://github.com/helm/helm)
 
For Azure based clusters, you will also need the `az` command line tool:

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Creating a new Cluster Environment

In bedrock, each physical cluster that you deploy has a corresponding environment that captures its configuration. 

The typical way to create a new environment is to copy an existing one. For example, for an AKS cluster, copy our aks-flux template environment to a new subdirectory with the name of your cluster:

```bash
$ cp -r environments/azure/aks-flux environments/azure/<cluster name>
```

Next, edit `environments/azure/<cluster name>/cluster.tfvars` and update the following variables (for a full list of customizable variables see [inputs.tf](./azure/aks-flux/inputs.tf)):

- `resource_group_name` - Name of the resource group for the cluster
- `cluster_name` - Name of the cluster itself
- `dns_prefix`: Base DNS name for accessing the cluster from the internet.
- `service_principal_id`, `service_principal_secret`: The id and secret of the service principal used by the AKS cluster.  This is generated using the Azure CLI (see [Creating Service Principal](#creating-service-principal) for details).
- `ssh_public_key`: Contents of a public key authorized to access the virtual machines within the cluster.
- `gitops_ssh_key`: Path to the *private key file* that was configured to work with the Gitops repository.
- `gitops_url`: The git repo that contains the resource manifests that should be deployed in the cluster in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-materialized.git`). This repo must have a deployment key configured to accept changes from `gitops_ssh_key` (see [Configuring Gitops Repository for Flux](#setting-up-gitops-repository-for-flux) for more details).

## Deploying Cluster

Bedrock requires a bash shell for the executing the automation it runs under. Currently MacOSX, Ubuntu, and the Windows Subsystem for Linux (WSL) are supported.

To deploy into Azure, Terraform relies on a set of four environmental variables to provide it with the 
authorization it needs to deploy the cluster. Set these in your shell with a service principal that is authorized to create infrastructure for the desired subscription (see [Creating Service Principal](#creating-service-[rincipal) below for details) before you start deployment:

```
export ARM_SUBSCRIPTION_ID=xxxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy
export ARM_CLIENT_ID=xxxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy
export ARM_CLIENT_SECRET=xxxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy
export ARM_TENANT_ID=xxxxxxxxx-yyyy-zzzz-xxxx-yyyyyyyyyyyy
```

Then, from the directory of the cluster you defined above (eg. `environments/azure/<cluster name>`), run:

```
$ terraform init
```

This will download all of the modules needed for the deployment.  You can then deploy the cluster with:

```
$ terraform apply -var-file=./cluster.tfvars
```

This will display the plan for what infrastructure Terraform plans to deploy into your subscription and ask for your confirmation.

Once you have confirmed the plan, Terraform will deploy the cluster, install [Flux](https://github.com/weaveworks/flux)
in the cluster to enable a [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow, and deploy any resource manifests in the `gitops_url`.

Once your cluster has been created the credentials for the cluster will be placed in the specified `output_directory` which defaults to `./output`. 

You can copy this to your `~/.kube/config` by executing:

```bash
$ KUBECONFIG=./output/kube_config:~/.kube/config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config
```

or directly use the kube_config file with:

```
$ KUBECONFIG=./output/kube_config kubectl get po --namespace=flux` 
```

### Creating Service Principal

You can generate an Azure service principal for a particular subscription with the following `az` cli command:

```bash
$ az ad sp create-for-rbac --subscription 
{
  "appId": "50d65587-abcd-4619-1234-f99fb2ac0987",
  "displayName": "azure-cli-2019-01-23-20-27-37",
  "name": "http://azure-cli-2019-01-23-20-27-37",
  "password": "3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

### Setting Up Gitops Repository for Flux

Flux watches a Git repository that contains the resource manifests that should be deployed into the Kubernetes cluster, and, as such, we need to configure that repo and give Flux permissions to access it, and cluster creation time.

1.  Create the repo to use for Gitops (this example will assume that you are using Github, but Gitlab and Azure Devops are also supported).
2.  Create/choose an SSH key pair that will be given permission to do read/write access to the repository.  You can create an ssh key pair with the following:

```bash
$ ssh-keygen -b 2048 -t rsa -f gitops_repo_key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in gitops_repo_key.
Your public key has been saved in gitops_repo_key.pub.
The key fingerprint is:
SHA256:DgAbaIRrET0rM/U5PIT0mcBFVMW/AQ9sRJ/TsdcmmFA
The key's randomart image is:
+---[RSA 2048]----+
|o+Bo=+..*+..E.   |
|oo Xo.o  *..ooo .|
|..+ B+. . =+oo..o|
|.= . B     +. .o |
|. +   + S   o    |
|       o   .     |
|        .        |
|                 |
|                 |
+----[SHA256]-----+
$ ls -l gitops_repo_key*
-rw-------  1 jims  staff  1823 Jan 24 16:28 gitops_repo_key
-rw-r--r--  1 jims  staff   398 Jan 24 16:28 gitops_repo_key.pub
```

3.  Add the SSH key to the repository

Flux currently requires write access to the git repository to store reconcilation state. For Github, the process to add a deploy key is documented 
[here](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/).

### Terraform State

When one isses a `terraform apply`, Terraform records the information about what is created in a [Terraform state file](https://www.terraform.io/docs/state/).  By default, the directory in which `terraform apply` is executed in will create a file named `terraform.tfstte`.  Terraform needs this information to know the state of the cluster for future modifications to the infrastructure.

In devops / production scenarios, storing the state file on a local file system may not be the desired scenario.  Terraform supports storing state remotely.  One of those possible locations is in an Azure Blob Store.  This is defined using a `backend` block.  The basic block looks like:

```bash
terraform {
   backend “azure” {
   }
}
```

In order to setup an Azure backend, navigate to the [backend state](http://github.com/Microsoft/bedrock/cluster/azure/backend-state) directory.  And issue the following command:

```bash
> terraform apply -var 'name=<storage account name>' -var 'location=<storage account location>' -var 'resource_group_name=<storage account resource group>'
```

`storage account name` is the name of the stroage account to store the Terraform state.  `storage account location` is the Azure region the storage account is created in.  `storage account resource group` is the name of the resource group to create the storage account in.  

Once the storage account is created, one must determine the storage account key.  To determine that, issue the command:

```bash
>  az storage account keys list --account-name <storage account name>
```

Once the above is completed, update the `backend.tfvars` file and use `terraform init` as follows `terraform init -backend-config=./backend.tfvars` to setup usage of the Azure backend.