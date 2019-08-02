# Bedrock

[![Build Status](https://dev.azure.com/epicstuff/bedrock/_apis/build/status/Microsoft.bedrock?branchName=master)](https://dev.azure.com/epicstuff/bedrock/_build/latest?definitionId=54&branchName=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/microsoft/bedrock)](https://goreportcard.com/report/github.com/microsoft/bedrock)

This project is our humble attempt to combine the collective wisdom of the cloud native community for building best practice cloud native Kubernetes clusters, based on real world experiences deploying and operating applications and Kubernetes clusters.

Bedrock is a set of automation, tooling, and infrastructure for deploying production-level Kubernetes clusters with a secure and auditable [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow.  

In our implementation of this methodology, you build a [Fabrikate](https://github.com/Microsoft/fabrikate) high level deployment definition of what should be deployed in your cluster. We believe that defining your deployment at this higher level of abstraction is less error prone than directly editing resource manifest files or cobbling together shell scripts to build resource manifests from Helm templates, and allows you to leverage common pieces across many deployments and to share structure amongst different clusters differentiated by config.

A CI/CD pipeline then generates Kubernetes resource manifests from these Fabrikate high level definitions. On each commit to the high level definition repo, this CI/CD pipeline uses Fabrikate to generate resource manifests from this definition and checks them into a resource manifest git repo. This resource manifest repo both specifies exactly what should be deployed and also maintains an audit trail of all of the low level operational changes. This combination of high level definition and resource manifest repos allow you to secure, control, code review, and audit what is currently deployed at both a high and low level.

Bedrock also provides automation for deploying Kubernetes clusters with Terraform, including deployment and setup of [Flux](https://github.com/weaveworks/flux), which automates the application of the resource manifests specified.

## Getting Started

A Bedrock deployment follows three general steps at a high level:

1. [Create and deploy azure-simple](./docs/azure-simple/README.md) a Kubernetes environment that uses Flux.
2. Define a [Fabrikate](./docs/fabrikate/README.md) definition.
3. [Deploy a CI/CD pipeline](./docs/devops/README.md) to build resource manifests for this deployment. 

Our cluster creation templates include deployments of a [cloud-native stack](https://github.com/timfpark/fabrikate-cloud-native) by default.  This is intended to be replaced with your own resource manifest repo, but you can also take advantage of this by jumping directly to step #3 if you'd like to give Bedrock a try before defining your own deployment.

The easiest way to try Bedrock is to start with our [azure-simple](./docs/azure-simple/README.md) deployment. 

## Community

[Please join us on Slack](https://join.slack.com/t/bedrockco/shared_invite/enQtNjIwNzg3NTU0MDgzLTdiZGY4ZTM5OTM4MWEyM2FlZDA5MmE0MmNhNTQ2MGMxYTY2NGYxMTVlZWFmODVmODJlOWU0Y2U2YmM1YTE0NGI) for discussion and/or questions.

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
