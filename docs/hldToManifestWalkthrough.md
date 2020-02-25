# Setting up an HLD to Manifest pipeline

In [First Workload](./firstWorkload/README.md) we deployed the Azure Vote App using a GitOps workflow by pushing the `azure-vote-all-in-one-redis.yaml` Kubernetes resource manifest file. In [High level Deployment Definitions](./high-level-definitions.md) we learned that, Kubernetes resource manifests that comprise an application definition are typically very complex. These resource manifests, by their YAML nature, are typically very dense, context free, and very indentation sensitive -- making them a dangerous surface to directly edit without introducing a high risk for operational disaster.

We also learned that real world Kubernetes deployments tend to be composed of the combination of many Helm charts. Maintaining and generating various Helm charts can be a challenge. This is why Bedrock introduces High Level Deployment Definitions.

In this walkthrough, we will:
1. Set up an Azure DevOps pipeline that generates a resource manifest from an HLD definition for the Azure Vote App and pushes it to the Manifest Repository.

## Required Tools
1. [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
2. [Git](https://git-scm.com/) version [2.22](https://github.blog/2019-06-07-highlights-from-git-2-22/) or later
3. The latest [spk release](https://github.com/catalystcode/spk/releases)

## Prerequisites
To deploy a manifest generation pipeline you will need:

1. Personal Access Token in Azure DevOps with this permissions:
    - Build (Read & execute)
    - Code (Read, write, & manage)
    - Variable Groups (Read, create, & manage) 
    
    To create one, follow [these instructions](https://github.com/CatalystCode/spk/blob/master/guides/project-service-management-guide.md#generate-personal-access-token).
2. An [spk-config.yaml](https://github.com/CatalystCode/spk/blob/390acbc8ab3ed20082bd50657eab16402e37144c/spk-config.yaml) file.
3. An Azure DevOps organization. If you're starting from scratch, [create a new Azure DevOps Organization](https://docs.microsoft.com/en-us/azure/devops/user-guide/sign-up-invite-teammates?view=azure-devops).
4. An Azure DevOps project inside the organization from Step 3. [Create a project in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/user-guide/sign-up-invite-teammates?view=azure-devops#create-a-project).
5. A Manifest Repository inside the Azure DevOps project from Step 4. [Create a repository](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops).
6. An HLD Repository inside the Azure DevOps project from Step 4. [Create a repository](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops).

## Configuring SPK
From the starter template you download in Step 2 of the [Prerequisites](#prerequisites), change the values for the `azure_devops` section to match your resources.

**Note:** This spk-config.yaml should not be commited anywhere, as it contains sensitive credentials like the Personal Access Token. For a scenario where the PAT is not in the spk-config.yaml, plese refer to these [steps](https://github.com/catalystcode/spk#creating-environment-variables).

Run `spk init -f <spk-config.yaml>` where `<spk-config.yaml>` the path to the configuation file.

## High Level Definition Repository
This repository holds the Bedrock High Level Deployment Definition (HLD) and associated configurations.

This HLD is processed via [fabrikate](https://github.com/microsoft/fabrikate) in Azure Devops on each change to generate Kubernetes YAML manifests that are applied to the Kubernetes cluster by Flux.

### Initializing the High Level Definition Repository
- Clone the repository you created in Step 6 of the [Prerequisites](#prerequisites).
- Initialize the HLD repository via SPK, this will add the fabrikate [traefik2](https://github.com/microsoft/fabrikate-definitions/tree/master/definitions/traefik2) as the initial sample component. This can be overridden via optional flags.

```
spk hld init --default-component-git https://github.com/edaena/azure-vote-hld --default-component-name azure-vote --git-push
```

The `spk hld` API documentation can be found [here](https://github.com/CatalystCode/spk/blob/master/guides/hld-management.md).


