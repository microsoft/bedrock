# Bedrock

[![Build Status](https://dev.azure.com/epicstuff/bedrock/_apis/build/status/Microsoft.bedrock?branchName=master)](https://dev.azure.com/epicstuff/bedrock/_build/latest?definitionId=54&branchName=master)
[![Go Report Card](https://goreportcard.com/badge/github.com/microsoft/bedrock)](https://goreportcard.com/report/github.com/microsoft/bedrock)

Bedrock is automation and tooling for operationalizing production Kubernetes clusters with a [GitOps](./gitops) workflow.  GitOps enables you to build a workflow around your deployments and infrastructure similiar to that of a typical development workflow: pull request based operational changes, point in time auditability into what was deployed on the Kubernetes cluster, and providing nonrepudation about who made those changes.

This GitOps workflow revolves around [Fabrikate](https://github.com/Microsoft/fabrikate) definitions that enable you to specify your deployments at a higher level of abstraction that enables you to separate structure from configuration that makes them easier to maintain versus directly specifying them as Kubernetes resource manifest YAML or cobbling together shell scripts to build Kubernetes resource manifests from templating solutions.  Fabrikate definitions also allow you to leverage common pieces across many deployments and to share structure amongst different clusters differentiated only by config.

Bedrock also provides [guidance and automation](./gitops/README.md) for building GitOps pipelines with a variety of popular CI/CD orchestrators.

Finally, Bedrock provides a set of Terraform environment templates for deploying your Kubernetes clusters, including automation for setting up the GitOps Operator [Flux](https://github.com/fluxcd/flux) in your cluster.

## Getting Started

A Bedrock deployment follows three steps at a high level:

1. [Create and deploy](./cluster/README.md) a GitOps enabled Kubernetes cluster.
2. Define a [Fabrikate](https://github.com/microsoft/fabrikate) high level deployment definition.
3. [Setup a GitOps pipeline](./gitops/README.md) to automate deployments of this definition to this cluster based on typical application and cluster lifecycle events.

The steps required to operationalize a production Kubernetes cluster can be pretty extensive, so we have also put togeter a [simple walkthrough for deploying a first cluster](./docs/azure-simple/README.md) that makes a great first step.

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
