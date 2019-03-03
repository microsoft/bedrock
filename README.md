# Bedrock

[![Build Status](https://travis-ci.org/Microsoft/bedrock.svg?branch=master)](https://travis-ci.org/Microsoft/bedrock)

This project is our humble attempt to combine the collective wisdom of the cloud native community for 
building best practice cloud native Kubernetes clusters, based on real world experiences 
deploying and operating applications in Kubernetes clusters.

In particular, Bedrock is a set of automation, tooling, and infrastructure for deploying production-level Kubernetes
clusters with a secure and auditable [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow.  

In our implementation of this methodology, you build a [Fabrikate](https://github.com/Microsoft/fabrikate) high level deployment definition of what should be deployed in your cluster. We believe that defining your deployment at this higher level of abstraction is less error prone than directly editing resource manifest files or cobbling together shell scripts to build resource manifests from Helm templates, and allows you to leverage common pieces across many deployments and to share structure amongst different clusters differentiated by config.

A CI/CD pipeline generates Kubernetes resource manifests from these Fabrikate high level definitions. On each commit to the high level definition repo, this CI/CD pipeline uses Fabrikate to generate resource manifests from this definition and then checks them into a resource manifest git repo. This resource manifest repo both specifies exactly what should be deployed and also maintains an audit trail of all of the low level operational changes that have been made. This combination of this high level definition and the resource manifest repos allow you to secure, control, code review, and audit what is currently deployed at both a high and low level.

Bedrock also provides automation for deploying Kubernetes clusters with Terraform, including deployment and setup of [Flux](https://github.com/weaveworks/flux), which automates the application of the resource manifests specified.

## Getting Started

A Bedrock deployment follows three general steps:

1. Define a [Fabrikate](https://github.com/Microsoft/fabrikate) definition for your deployment.
2. [Deploy a CI/CD pipeline](./gitops) to build resource manifests from this deployment definition.
3. [Create and deploy](./cluster) a Kubernetes environment with Flux.

Our cluster creation templates include deployments of a [cloud-native stack](https://github.com/timfpark/fabrikate-cloud-native). Given this, you can start with a cluster deployment using step #3 if you'd like to give Bedrock a try before defining your own deployment.

## Contributing

We do not claim to have all the answers and would greatly appreciate your ideas and pull requests.

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

For project related questions or comments, please contact [Tim Park](https://github.com/timfpark).
