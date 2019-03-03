# GitOps

A [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow uses a git workflow to build, code review, and deploy operational changes to your system.

In Bedrock's implementation of this methodology, one builds a high level [Fabrikate](https://github.com/Microsoft/fabrikate)  definition of what should be deployed in your cluster. This high level definition separates the structure of the deployment from its configuration, enabling it to be used across multiple cluster deployments, to be version controlled in a git repo, and have operations be backed by the same solid engineering practices like pull requests, code reviews, and automated validation and linting that are utilized for code changes.

On a commit to the high level definition repo, a CI/CD system uses Fabrikate to generate the low level Kubernetes resource manifests for the deployment.  These low level Kubernetes resource manifests are checked into a corresponding repo that serves as the operational "source of truth" for what should be deployed in the Kubernetes cluster. Finally, [Flux](https://github.com/weaveworks/flux), running inside of the Kubernetes cluster, watches for commits to this repo and reconciles the cluster to it.

<img src="images/GitOpsFlow.png?sanitize=true">

## Process

At a high level, the steps for an operator of a Kubernetes cluster to make an operational change follow closely the model that one uses for making a code change in a pull request model.

1. _Branch_: Create a branch and then make one or more commits for your operational change to your high level definition.
2. _Push_: Push this branch to your high level definition Git repo.
3. _Pull Request_: Create a pull request for your change and have it code reviewed by a member of your team while the CI/CD system validates your changes.
4. _Merge_: Merge your pull request into your high level definition's git repo master branch.  A CI/CD pipeline will trigger on this commit, build the low level Kubernetes resource manifests, check them into the resource manifest git repo, which [Flux](https://github.com/weaveworks/flux), running in your Kubernetes cluster, will deploy.
5. _Monitor_: Monitor your normal operational metrics to verify that the change has not negatively impacted your application.
6. _Repeat_

## Getting Started

We provide instructions and automation for deploying a GitOps CI/CD pipeline for the following platforms:

* [Azure Devops](./azure-devops)

Pull requests would be gratefully accepted for other CI/CD platforms.

### Additional Resources
+ https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/use-git-microsoft
+ https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/release-flow
+ https://docs.microsoft.com/en-us/azure/aks/best-practices
