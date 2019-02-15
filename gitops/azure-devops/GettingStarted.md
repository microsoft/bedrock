# Getting Started with Azure DevOps and GitOps  
The expectation here is that from scratch you can set up the necessary repos to get a Bedrock GitOps release flow™ working. 

## Requirements
+ You belong to an Azure DevOps _organization_ and having permission to create _projects_
+ Permissions to create GitHub Personal Access Token (if using GitHub Repos)

## 1. Set Up Repositories

We provide instructions for creating HLD and Manifest repos in two flavors:
* [Azure DevOps](ADORepos.md)
* [GitHub](GitHubRepos.md)

## 2. Create an Azure DevOps Build Pipeline

Configuration of an [Azure Pipelines Build](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts?toc=/azure/devops/pipelines/toc.json&bc=/azure/devops/boards/pipelines/breadcrumb/toc.json&view=azure-devops) is necessary. We provide a YAML configration file in the sample HLD repository that performs the following behaviors:

+ On a pull request (pre push to master) will execute a simple validation on proposed changes to infrastructure definition in the HLD repo.

+ On a merge to master branch (post push to master) we execute a script to transform the high level definition to YAML using [Microsoft Fabrikate](https://github.com/Microsoft/fabrikate) and push it to the manifest repository.

### Create a Build from your HLD Repo

In the Azure DevOps,
1. Click on "Pipelines" on the left side to expand a submenu
2. Click on "Builds" from the submenu
3. In the 2nd column from the left click the "+ New" button
4. Select "New build pipeline"
5. Choose "Azure Repos" as the selection to the "Where is your code?" prompt
6. Choose the repo that you named as $HLD_REPO_NAME

### Configure a Build

At this point you will see `azure-pipeline.yml`, which is contained in the HLD repo.
1. Click the blue run button on the right side.
2. You should see the output of an azure pipeline. Instead of waiting for the build to finish, click the ellipsis (...) in the upper right corner and choose "Edit pipeline".
3. You will see the YAML contents again. Click on the ellipsis to the right of the blue "Run" button and choose "Pipeline settings".
4. Click the "Variables" tab.
5. Add two variables:
    1. __Name__ AKS_MANIFEST_REPO __Value__ MANIFEST_REPO_NAME_GIT_URL
    2. __Name__ ACCESS_TOKEN __Value__ MANIFEST_REPO_NAME_GIT_URL
    3. __Name__ GIT_HOST __Value "azure"
    These variables are consumed by the `build.sh` called in `azure_pipeline.yml`.
6. Click "Save & Queue".
7. You will see the build run and hopefully complete successfully. At this point we can make a PR change to the HLD repo.

### Azure Pipelines Build YAML
```
trigger:
- master

pool:
  vmImage: 'Ubuntu-16.04'

steps:
- checkout: self
  persistCredentials: true
  clean: true

- bash: |
    chmod +x ./build.sh && ./build.sh --verify-only
  condition: eq(variables['Build.Reason'], 'PullRequest')

- task: ShellScript@2
  inputs:
    scriptPath: build.sh
  condition: ne(variables['Build.Reason'], 'PullRequest')
  env:
    ACCESS_TOKEN: $(accesstoken)
    COMMIT_MESSAGE: $(Build.SourceVersionMessage)
    AKS_MANIFEST_REPO: $(aks_manifest_repo)

```
## 3. Configure Flux

Once you have your Azure DevOps repos in place and the Azure Pipelne Build working, you will need to configure Flux with the Manifest Repo. To do this, [Flux](https://github.com/weaveworks/flux/blob/master/site/get-started.md) has an easy-to-follow guide on setting this up.

__Note__: If you followed [instructions](../../cluster/README.md#setting-up-gitops-repository-for-flux) to setup a flux enabled AKS cluster then copy the contents of your public SSH key and skip to step #4 below

1. Deploy Flux to an cluster by editing the `flux-deployment.yml` as necessary, and then running `kubectl apply -f deploy`
2. Generate an SSH key by running `fluxctl identity`.
3. Copy the SSH key.
4. In Azure DevOps, under your User Profile > Security > SSH public keys, click on `Add` and add the Flux deploy key.

Now, when a change is commited to the Manifest repo, Flux should acknowledge the commit and make changes to the state of your cluster as necessary. You can monitor Flux by viewing the logs by running `kubectl -n default logs deployment/flux -f` (or whichever namespace was specified for Flux at deployment, in this case Flux was deployed in the default namespace)

## 4. Make a Pull Request
1. Create a new branch in your HLD repo and make a commit to the high level definition such as ....
2. From GitHub perform pull request to merge your changes into master branch
3. Once checks has passed have the PR approved 

## 5. Monitor Repository Changes
Once a pull request is approved you can monitor the progress of the HLD transformation in the Build menu in your Azure DevOps _Project_.

![ADO Build](images/ADO_builds.png)

Once the build is successful navigate to your manifest repository. You see a very recent commit to the main branch.

## 6. Monitor Cluster Changes

* Use [Flux](https://github.com/weaveworks/flux/blob/master/site/get-started.md#confirm-the-change-landed) to provide automated deploy synchronization between your manifest repo and cluster. 
* Use [Kubediff](https://github.com/weaveworks/kubediff) to make sure your cluster configuration and matches your manifest repo configuration

## 7. Repeat As Necessary
At this point a cycle of a GitOps flow has completed. To make additional changes to your cluster visit [Step 4](#4.-Make-a-Pull-Request). 

## Reference
* [Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?toc=/azure/devops/pipelines/toc.json&bc=/azure/devops/boards/pipelines/breadcrumb/toc.json&view=azure-devops)
