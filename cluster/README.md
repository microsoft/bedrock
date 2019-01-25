# Cluster Deployment

Bedrock automates cluster deployments with [Terraform](https://www.terraform.io).

Azure is currently the only provider supported, but we would welcome pull requests for other clouds.

## Setup

Bedrock's cluster creation automation requires `kubectl` for interacting with Kubernetes clusters, and `Terraform` for infrastructure automation.  If you haven't already, install them:

- [terraform](https://www.terraform.io/intro/getting-started/install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
 
For Azure based clusters, you also need to have the `az` command line tool:

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Creating a new Cluster Environment

In bedrock, each cluster is defined in an environment that captures its configuration.  To create a new cluster environment, one typically copies an existing cluster environment to use as a template for your deployment.  For example, for an AKS cluster:

```bash
$ cp -r environments/azure/aks-flux environments/azure/my-cluster
```

The next step is to edit `environments/azure/my-cluster/cluster.tfvars` (or whatever name you chose for your cluster) and update the following variables (for a full list of customizable variables see `inputs.tf`):

- `resource_group_name` - Name of the resource group for the cluster
- `cluster_name` - Name of the cluster itself
- `dns_prefix`: Base DNS name for accessing the cluster from the internet
- `service_principal_id`, `service_principal_secret`: The id and secret of the service principal used to deploy the AKS cluster.  This is generated using the Azure CLI (see [Creating Service Principal](#creating-service-principal) for generation details).
- `ssh_public_key`: Contents of the public key which is used to access virtual machines within the cluster
- `gitops_ssh_key`: Path to the *private key file* that was configured to work with the Gitops repository
- `gitops_url`: The git repo to use as the repository of truth in ssh format (eg. `git@github.com:timfpark/fabrikate-cloud-native-materialized.git`). This repo must have a deployment key configured to accept changes from `gitops_ssh_key` (see [Configuring Gitops Repository for Flux](#setting-up-gitops-repository-for-flux) for more details).

In the configuration above, `service_principal_id` should be set to `appId` and `service_principal_secret` set to `password`.

## Deploying Cluster

To deploy the cluster you have defined, execute the following two steps from your cluster environment's directory (eg. `environments/azure/my-cluster`):

```
$ terraform init
```

This will download all of the Terraform modules needed for the deployment.  You can then deploy the cluster with:

```
$ terraform apply -var-file=./cluster.tfvars
```

This will deploy the infrastructure for your cluster and install [Flux](https://github.com/weaveworks/flux)
in the cluster. Flux is an open source project that enables a [gitops](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow to deploy resources in a Kubernetes cluster. 

Its operational model is very simple: it monitors a specific git repository that Kubernetes resource
manifest files are checked into, and when it detects a change to those resource manifests, it applies those changes to the cluster. 

Once your cluster has been created the credentials for the cluster will be placed in the specified `output_directory` which defaults to `./output`. 

You can copy this to your `~/.kube/config` by executing:

```bash
$ KUBECONFIG=~/.kube/config:./output/kube_config kubectl config view --flatten > merged-config && mv merged-config ~/.kube/config
```

or directly use the kube_config file ala:

```
$ KUBECONFIG=./output/kube_config kubectl get po --namespace=flux` 
```

### Creating Service Principal

If you do not already have a Azure service principal, you can generate one via:

```bash
$ az ad sp create-for-rbac
{
  "appId": "50d65587-abcd-4619-1234-f99fb2ac0987",
  "displayName": "azure-cli-2019-01-23-20-27-37",
  "name": "http://azure-cli-2019-01-23-20-27-37",
  "password": "3ac38e00-aaaa-bbbb-bb87-7222bc4b1f11",
  "tenant": "72f988bf-86f1-41af-91ab-2d7cd011db47"
}
```

### Setting Up Gitops Repository for Flux

Flux requires a repository to monitor in order to deploy services to the Kubernetes cluster.  

1.  Create the repo to use for Gitops (this example will assume that you are using Github).
2.  Create (or choose) an SSH key pair that will be given permission to do read/write access to the repository.  Use either
an existing SSH key or to generate an unencrypted key (using linux):

```bash
$ ssh-keygen -b 2048 -t rsa -f gitops_repo_key
Generating public/private rsa key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in gitops_repo_key.
Your public key has been saved in gitops_repo_key.pub.
The key fingerprint is:
SHA256:DgAbaIRrET0rM/U5PIT0mcBFVMW/AQ9sRJ/TsdcmmFA jims@tiremunchie
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

Flux requires write access to the git repository to store reconcilation state. For Github, the process to add a deploy key is documented 
[here](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/).