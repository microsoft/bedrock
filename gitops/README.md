# GitOps

A [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow uses a git workflow to build, code review, and deploy operational changes to your system.

In Bedrock's version of this methodology, we define what should be deployed in your cluster via a high level [Fabrikate](https://github.com/Microsoft/fabrikate) definition. This high level definition separates the structure of the deployment from its configuration, enabling it to be used across multiple cluster deployments, to be version controlled in a git repo, and have changes to be backed by the same solid engineering practices like pull requests, code reviews, and automated validation and linting that we utilize for code changes.

On a commit to the high level definition repo, a CI/CD system uses Fabrikate to generate the low level Kubernetes resource manifests for the deployment.  These low level Kubernetes resource manifests are checked into a corresponding repo that serves as the operational "source of truth" for what should be deployed in the Kubernetes cluster. Finally, [Flux](https://github.com/weaveworks/flux), running inside of the Kubernetes cluster, watches for commits to this repo and reconciles the cluster to it.

<img src="images/GitOpsFlow.png?sanitize=true">

This section describes how to deploy and configure such a CI/CD system in support of your GitOps workflow.

## Process

At a high level, the steps for an operator of a Kubernetes cluster to make an operational change follow closely the model that one uses for making a code change in a pull request model.

1. _Branch_: Create a branch and then make one or more commits for your desired changes to your high level definition.
2. _Push_: Push this branch to your high level definition Git repo.
3. _Pull Request_: Create a pull request for your change.  This enables you to have it it code reviewed by a member of your team while also enabling the CI/CD system to validate your changes.
4. _Merge_: Merge your pull request into your high level definition's git repo master branch.  A CI/CD pipeline will trigger on this commit, build the low level Kubernetes resource manifests, check them into the resource manifest git repo, which [Flux](https://github.com/weaveworks/flux), running in your Kubernetes cluster and watching this repo, will deploy.
5. _Monitor_: Monitor your normal operational metrics to verify that the change has not negatively impacted your application.
6. _Repeat_

## Getting Started

Learning about how we think about designing GitOps Pipelines:

* [GitOps Pipeline Design](./PipelineThinking.md)

We provide instructions and automation for deploying a GitOps CI/CD pipeline for the following platforms:

* [Azure Devops](./azure-devops)
* [Octopus Deploy](./octopus)
* [TeamCity](./teamcity)
* [Jenkins](./jenkins)

Pull requests would be gratefully accepted for other CI/CD platforms.

## Beyond Getting Started

Got through the examples? Learn about how to refine your GitOps pipelines for production use.

* [GitOps Best Practices](BestPractices.md)
* [Operating Private Repositories](PrivateRepositories.md)

## Additional Questions?

Check out the [wiki](https://github.com/Microsoft/bedrock/wiki/FAQ#gitops) pages.

### Additional Resources
+ https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/use-git-microsoft
+ https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/release-flow
+ https://docs.microsoft.com/en-us/azure/aks/best-practices
