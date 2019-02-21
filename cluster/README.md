# Getting Started

Bedrock automates Kubernetes cluster deployments with Terraform to provide full reproducibility of cluster operations.

## Required Tools

Bedrock uses three tools to automate cluster deployments that you'll need to install if you don't already have them:

- [terraform](https://www.terraform.io/intro/getting-started/install.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://github.com/helm/helm)

## Creating a new Cluster Environment

Bedrock provides templates for creating Kubernetes clusters for each supported cloud provider (currently only Azure -- but we would gratefully accept pull requests for other cloud providers).  Follow the instructions for the cloud provider you'd like to create a cluster environment for to get started:

- [Creating a new cluster on Azure](./azure)