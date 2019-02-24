# Bedrock

This project is our humble attempt to combine the collective wisdom of the cloud native community for 
building best practice cloud native Kubernetes clusters, based on real world experiences 
deploying and operating applications in Kubernetes clusters.

In particular, Bedrock is a set of automation, tooling, and infrastructue stacks for deploying production-level Kubernetes 
clusters with a secure and auditable [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow.  

In our version of this methodology, you assemble a [Fabrikate](https://github.com/Microsoft/fabrikate) high level deployment definition to define what should be deployed in your cluster.  This higher level construct avoids having to edit low level error prone resource manifest files, leverage common pieces across many deployments, and allow you to share structure amongst clusters with different applied config.

Next, you configure a CI/CD pipeline that generates the Kubernetes resource manifests from these Fabrikate definitions on each change and checks these generated resource manifests into a deployment git repo.  This resource manifest repo maintains an audit trail of all of the low level operational changes that have been made, allowing you to secure, control, code review, and audit what is currently deployed.

Finally, we provide cluster environment templates for automating the creation of Kubernetes clusters with [Flux](https://github.com/weaveworks/flux), which automatically reconciles your Kubernetes cluster to your resource manifest repo.

## Getting Started

1. Define a [Fabrikate](https://github.com/Microsoft/fabrikate) deployment definition for your deployment.
2. [Deploy a CI/CD pipeline](./gitops) to build resource manifests from this deployment definition.
3. [Create and deploy](./cluster) a Kubernetes environment with Flux.

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
