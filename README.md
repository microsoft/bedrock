# Bedrock

[![Build Status](https://dev.azure.com/epicstuff/bedrock/_apis/build/status/Microsoft.bedrock?branchName=master)](https://dev.azure.com/epicstuff/bedrock/_build/latest?definitionId=54&branchName=master)

Bedrock is a set of automation and tooling for deploying production-level Kubernetes clusters with a secure and auditable [GitOps](./gitops) workflow, based the learnings we've had deploying and operating real world applications and Kubernetes clusters with our customers.

Bedrock provides automation for deploying and maintaining the infrastructure surrounding your Kubernetes clusters with Terraform, including deployment and setup of [Flux](https://github.com/weaveworks/flux), which automates the application of the resource manifests specified.

It also includes automation for building CI/CD pipelines for building and releasing changes to your Kubernetes cluster from a higher level [Fabrikate](https://github.com/Microsoft/fabrikate) definition. Defining your deployment at this higher level of abstraction is less error prone than directly editing resource manifest files or cobbling together shell scripts to build resource manifests from Helm templates, and allows you to leverage common pieces across many deployments and to share structure amongst different clusters differentiated by config.

On each commit to the high level definition repo, this CI/CD pipeline uses Fabrikate to generate resource manifests from this definition and checks them into a resource manifest git repo. This resource manifest repo both specifies exactly what should be deployed and also provides an audit trail of all of the low level operational changes. This combination of high level definition and resource manifest repos allow you to secure, control, code review, and audit what is currently deployed at both a high and low level.

## Getting Started

A Bedrock deployment follows three steps at a high level:

1. [Create and deploy](./cluster) a Kubernetes environment starting from one of our Terraform environment templates.
2. [Deploy a GitOps CI/CD pipeline](./gitops) to build and release resource manifests from this deployment definition.
3. Define a [Fabrikate](https://github.com/Microsoft/fabrikate) definition for your deployment.

In addition to that in-depth documentation, we also maintain a [walkthrough for deploying the azure-simple environment template](./docs/azure-simple/README.md) that makes a great first step.

Finally, we also maintain a [FAQ](https://github.com/Microsoft/bedrock/wiki/FAQ) for answers to common questions.

## Releases

To support consistency in the deployment of Terraform based infrastructure.  Bedrock has started implementing releases for Terraform scripts.  The release process and tools for generating a release are found [here](./docs/releases).

The first release(s) will be 0.11.0 which will be the basic end of life for Terraform 0.11.x support and 0.12.0 which will be the first release supporting Terraform 0.12.x.

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
