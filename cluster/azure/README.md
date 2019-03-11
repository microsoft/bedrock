# Bedrock on Azure

## Summary

To get started with Bedrock on Azure, perform the following steps create an Azure Kubernetes Service (AKS) cluster using Terraform. 

- [Install required tools](#install-required-tools)
- [Set up GitOps repository for Flux](#set-up-gitops-repository-for-flux)
- [Azure Cluster Deployment](##Azure-Cluster-Deployment)

## Install required tools

As a first step, make sure you have installed the [pre-requisite tools](../README.md) on your machine.

Additionally, you need the Azure `az` command line tool in order to create and fetch Azure configuration info:

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Set up GitOps Repository for Flux

Flux watches a Git repository containing the resource manifests that should be deployed into the Kubernetes cluster, and, as such, we need to configure that repo and give Flux permissions to access it at cluster creation time.

1. Create a repo to use for GitOps. This example will assume that you are using one of the public git repo such as GitHub, Azure DevOps, GitLab, or BitBucket, but flux supports private git repos with [additional configuration](https://github.com/weaveworks/flux/blob/master/site/faq.md#how-do-i-use-a-private-git-host-or-one-thats-not-githubcom-gitlabcom-bitbucketorg-or-devazurecom).
2. Create/choose a SSH key pair that will be given permission to do read/write access to the repository. You can create an ssh key pair with the Bash `ssh-keygen` command as shown in the code block below.
3. Add the SSH public key to the repository. Flux requires read and write access to the resource manifest git repository. For GitHub, the process to add a deploy key is documented [here](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/). For Azure DevOps repos, the process is documented [here](https://docs.microsoft.com/en-us/azure/devops/repos/git/use-ssh-keys-to-authenticate?view=azure-devops).
4. Have your CI/CD pipeline run at least once and commit an initial set of resource manifests to your repo.  Flux requires at least one commit in your resource manifest repo to operate correctly.

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
$ ls -l GitOps_repo_key*
-rw-------  1 jims  staff  1823 Jan 24 16:28 GitOps_repo_key
-rw-r--r--  1 jims  staff   398 Jan 24 16:28 GitOps_repo_key.pub
```

## Azure Cluster Deployment
Bedrock currently have the following templates that you can choose to deploy in your Azure subscription by following template specific documentation.

- [azure-simple](../environments/azure-simple/): Single cluster deployment.
- [azure-multiple-clusters](../environments/azure-multiple-clusters/): Multiple clusters  deployment with Traffic Manager.
- [azure-advanced](../environments/azure-advanced): Single cluster deployment with Azure Keyvault integration through flex volumes.