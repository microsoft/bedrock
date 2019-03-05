# Getting Started

Bedrock automates Kubernetes cluster deployments with Terraform to provide full reproducibility of cluster operations.

## Required Tools

Bedrock uses three tools to automate cluster deployments that you'll need to install if you don't already have them:

- [terraform](https://www.terraform.io/intro/getting-started/install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://github.com/helm/helm)

Verify that these tools are added to your system's PATH in order to avoid errors during cluster deployment.  (Note to WSL users: You will need to either move the executables to /usr/local/bin, or modify ~/.bashrc to add them to PATH and persist the new additions across restarts.)

In addition, you need the Azure `az` command line tool in order to create and fetch Azure configuration info:

- [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

## Creating a new Cluster Environment

Bedrock provides templates for creating Kubernetes clusters for each supported cloud provider (currently only Azure -- but we would gratefully accept pull requests for other cloud providers).  Follow the instructions for the cloud provider you'd like to create a cluster environment for to get started:

- [Creating a new cluster on Azure](./azure)