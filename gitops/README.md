# GitOps: The Substrata 

There exist many opinions about _GitOps_. In Bedrock we attempt to take the best aspects of _DevOps_ and lean on Git for implicit auditing/security. 

## Why GitOps?

+ **Simplicity** - TODO
+ **Congruent with Kubernetes** - TODO
+ **More Secure** - TODO

## How we practice Gitops in Bedrock
We follow a version of a _Release Flow_. At a high level the steps for an operator of a Kubernetes cluster are:

    1. Branch
    2. Push
    3. PR
    4. Merge
    5. Monitor
    6. Repeat
<img src="images/GitOpsFlow.svg?sanitize=true">
## Defintions

### High Level Deployment Description (HLD) Repo
+ A specification of the helm charts to use to build a deployment of a logically higher level component
+ Simplifies the complexity and repeativeness of low level YAML
+ Lives in a git repository

### Manifest Repo
+ These are the `kubectl` friendly low level YAML that declare the desired cluster state. 
+ They live in a git repository and are the expected state of the cluster. 
+ The git repository they live in is considered the source of truth. 

### CI/CD
+ We leverage operational features of CI/CD platforms to build, test, deploy, and orchestrate processes. 

### Fabrikate
+ A [tool]() we use to transform high level declared infrastructure into manifests 
+ Used in the CI/CD process

## A GitOps scenario with Bedrock

1. Propose changes to your infrastructure
	+ Make a PR against your high level deployment descriptions.
2. Initial tests and checks 
	+ An extensible CI/CD platform is configured to make sure infrastructure changes are valid (linting, etc)
3. Resource Manifest generation (Infrastructure as Code)
	+ Publish resource manifests that represent the new changes to the Kubernetes cluster.
4. Rollout changes (deploy)
	+ Have a process to apply the manifest files to the Kubernetes cluster.
5. Monitor and Validate
	+ Is the cluster in the expected state?
6. Repeat
    + Go back to step #1

## Additional Resources
+ https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/use-git-microsoft
+ https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/release-flow
+ https://docs.microsoft.com/en-us/azure/aks/best-practices
