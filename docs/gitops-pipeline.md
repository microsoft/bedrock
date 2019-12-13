# The End to End GitOps Deployment Pipeline

As we described in [“Why GitOps?”](./why-gitops.md), a [GitOps](https://www.weave.works/blog/gitops-operations-by-pull-request) workflow uses a git workflow to build, code review, and deploy operational changes to your system.

We also have described how, in Bedrock, we define what should be deployed in your cluster via a [high level definition](./high-level-definitions.md) that is specified and built using [Fabrikate](https://github.com/Microsoft/fabrikate) to your resource manifest repo. This high level definition separates the structure of the deployment from its configuration, enabling it to be used across multiple cluster deployments, to be version controlled in a git repo, and have changes to be backed by the same solid engineering practices that we utilize for code changes like pull requests, code reviews, and automated validation and linting.

On a commit to the high level definition repo, a CI/CD system uses Fabrikate to generate the lower level Kubernetes resource manifests for the deployment.  These low level Kubernetes resource manifests are checked into a corresponding repo that serves as the operational "source of truth" for what should be deployed in the Kubernetes cluster. Finally, [Flux](https://github.com/weaveworks/flux), running inside of the Kubernetes cluster, watches for commits to this repo and reconciles the cluster to it.

![Example of manifest yaml generation pipeline](images/manifest-gen.png)
<p align="center"><i>Example of manifest yaml generation pipeline</i></p>

## Establishing a GitOps Workflow

One of the biggest advantages of the GitOps workflow over other approaches is that, because we do not need to expose the Kubernetes API for operational tasks, it is more secure than alternative approaches.

That said, a GitOps workflow requires establishing a solid process for reviewing and securing the high level definition and resource manifests repos. In general, we recommend that every change to the high level definition repo be made via a pull request that is reviewed by at least one other team member before being merged into master. We also recommend automatically building pull requests such that you can verify the output in addition to the change.

We also strongly encourage blocking direct operational changes on the Kubernetes cluster via `kubectl`, the Kubernetes dashboard, `helm` via tiller, or other less secure approaches.  While it might be tempting to shortcircuit the process “just this once”, these changes are not auditable and you will lose the nonrepudiation benefits of the GitOps process.

We also recommend enforcing branch policies on your repo such that:
+ No direct pushes to master, only via a pull request.
+ Required pull request approvers
+ Automated gating checks on pull requests

Links to how to set up branch policies on some git repository providers:
+ [Azure Dev Ops](https://docs.microsoft.com/en-us/azure/devops/repos/git/branch-policies?view=azure-devops)
+ [GitHub](https://help.github.com/en/articles/configuring-protected-branches)

## Upstream Pipelines

The high level definition to resource manifest generation pipeline is the core pipeline of Bedrock but it is often augmented with upstream pipelines to automate certain common operational tasks.

One frequently used example of this is a release pipeline that triggers on the push of a container to a container registry and automatically updates the image tag via a commit on a configuration file in the high level definition.

The high-level steps of this automated container image tag update are:
+ A build process that increments a build number and assigns a build image number as the image tag in a container registry.
+ Updating a Fabrikate template config file in high-level definition repo with the relevant image tag gets updated and a manifest generation pipeline may automatically get run
+ The cluster(s) should automatically get updated to the latest Kubernetes deployment

This commit to the high level definition in turn triggers the core GitOps pipeline, which generates the resource manifests with this image tag change. Flux picks this up in its next sync with the resource manifest repo and changes the image tag for the deployment in the cluster, thus completing the deployment.

Bedrock extensively utilizes these upstream pipelines to automate many operational tasks.

While Bedrock offers a first class implementation of these automation pipelines in Azure DevOps, GitOps pipelines in Bedrock, by their nature, are abstracted from each other via an intermediate git repo. This means that we can use different pipeline orchestrators as necessary to fit the needs of the particular development and operations teams. For instance, a Jenkins augmentation pipeline can be the prefix to an Azure DevOps manifest generation pipeline, and visa versa.

## Process

At a high level, the steps for an operator of a Kubernetes cluster to make an operational change follow closely the model that one uses for making a code change in a pull request model.

1. _Branch_: Create a branch and then make one or more commits for your desired changes to your high level definition.
2. _Push_: Push this branch to your high level definition Git repo.
3. _Pull Request_: Create a pull request for your change.  This enables you to have it it code reviewed by a member of your team while also enabling the CI/CD system to validate your changes.
4. _Merge_: Merge your pull request into your high level definition's git repo master branch.  A CI/CD pipeline will trigger on this commit, build the low level Kubernetes resource manifests, check them into the resource manifest git repo, which [Flux](https://github.com/weaveworks/flux), running in your Kubernetes cluster and watching this repo, will deploy.
5. _Monitor_: Monitor your normal operational metrics to verify that the change has not negatively impacted your application.
6. _Repeat_

## Rollbacks
Sometimes — even with solid engineering practices like branching, pull requests, and code reviews — changes to your application configuration can yield undesired results. Having the ability to easily rollback to a previous state application code configuration is a must have.

To maintain a commit history of every operation that has occurred on the cluster, we recommend doing a rollback that compensates for the changes that the wayward operation made.  For the last commit, you can do this in an automated manner with:

```bash
$ git revert HEAD
```

This will create a compensating commit with the inverse of the previous commit.
