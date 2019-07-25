# Bedrock

[![Build Status](https://dev.azure.com/epicstuff/bedrock/_apis/build/status/Microsoft.bedrock?branchName=master)](https://dev.azure.com/epicstuff/bedrock/_build/latest?definitionId=54&branchName=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/microsoft/bedrock)](https://goreportcard.com/report/github.com/microsoft/bedrock)

Bedrock is a collection of tools and infrastructure definitions combined in a secure and auditable [GitOps]([https://www.weave.works/blog/gitops-operations-by-pull-request](https://www.weave.works/blog/gitops-operations-by-pull-request)) workflow that is integrated in a Kubernetes Cluster.
Bedrock was designed from learnings from the cloud native community and from deploying and operating applications and Kubernetes clusters.

##### Components:
1. Infrastructure
2. Applications and Kubernetes Resources
3. CI/CD pipeline leveraging [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request)

#### Tools
For each Bedrock component, several tools are being used. Suggestions for supporting other tools is done by [submitting an issue](https://github.com/microsoft/bedrock/issues).

##### Infrastructure Tools:
- [Terraform](https://www.terraform.io/)


##### Applications and Kubernetes Resources Tools:
- [Fabrikate](https://github.com/microsoft/fabrikate)

> Fabrikate is a tool that allows you to write [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) resource definition and configuration for multiple environments. It leverages the [Helm](https://helm.sh/) chart ecosystem.

>Fabrikate components are High Level Definitions that get generated into Kubernetes resource manifest files.

##### CI/CD Tools:
- [Flux](https://github.com/fluxcd/flux/blob/master/chart/flux/README.md) for [GitOps](https://www.weave.works/technologies/gitops/)

- Pipelines: [Azure DevOps](https://github.com/microsoft/bedrock/blob/master/gitops/azure-devops), [Octopus Deploy](https://github.com/microsoft/bedrock/blob/master/gitops/octopus), [TeamCity](https://github.com/microsoft/bedrock/blob/master/gitops/teamcity), [Jenkins](https://github.com/microsoft/bedrock/blob/master/gitops/jenkins)

> Flux is a tool that runs in the Kubernetes cluster. It detects changes made to a resource manifest Repository and applies them.

## Getting Started
Building a Kubernetes cluster using Bedrock practices consists of the following process:

1. Building a [Fabrikate](https://github.com/Microsoft/fabrikate) **high level deployment definition** of the applications for your cluster.
2. Setting up a CI/CD pipeline that will generate Kubernetes resource manifests from the Fabrikate definitions.
3. The CI/CD pipeline checks in the generated resource manifests into a **resource manifest git repository**.
4. Setting up the cluster infrastructure

> Defining your deployment with Fabrikate **high level deployment definitions** is less error prone than directly editing resource manifests or cobbling together shell scripts to build resource manifests from Helm templates.

> The **resource manifest git repository** specifies exactly what should be deployed and also maintains an audit trail of all of the low level operational changes.

> The combination of **high level definitions** and **resource manifest repositories** allow you to secure, control, code review and adit what is currently deployed at a high and low level.

> Bedrock also provides automation for deploying Kubernetes clusters with Terraform, including deployment and setup of [Flux](https://github.com/weaveworks/flux), which automates the application of the resource manifests specified.

### Deployment Steps

1. Define a [Fabrikate](https://github.com/Microsoft/fabrikate) definition for your deployment.
2. [Deploy a CI/CD pipeline](./gitops) to build resource manifests from this deployment definition.
3. [Create and deploy](./cluster) a Kubernetes environment with Flux.

Our cluster creation templates include deployments of a [cloud-native stack](https://github.com/timfpark/fabrikate-cloud-native) by default.  This is intended to be replaced with your own resource manifest repo, but you can also take advantage of this by jumping directly to step #3 if you'd like to give Bedrock a try before defining your own deployment.

The easiest way to try Bedrock is to start with our [azure-simple](https://github.com/Microsoft/bedrock/tree/master/cluster/environments/azure-simple) deployment template or with [minikube](https://github.com/Microsoft/bedrock/tree/master/cluster/environments/minikube) to try it locally.   

## Community

[Please join us on Slack](https://join.slack.com/t/bedrockco/shared_invite/enQtNjIwNzg3NTU0MDgzLTdiZGY4ZTM5OTM4MWEyM2FlZDA5MmE0MmNhNTQ2MGMxYTY2NGYxMTVlZWFmODVmODJlOWU0Y2U2YmM1YTE0NGI) for discussion and/or questions.

Also read the [Bedrock FAQ](https://github.com/Microsoft/bedrock/wiki/FAQ) for answers to common questions.

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

For project level questions, please contact [Tim Park](mailto:tpark@microsoft.com).
