# Getting Started with Azure DevOps and GitOps  
The expectation here is that from scratch you can set up the necessary repos to get a bedrock gitops release flow™ working. 

## Requirements
+ An Azure DevOps organization and project
+ Permissions to create GitHub Personal Access Token

## Set Up

### Create Manifest Repository
You will also need a destination repository where the kubectl friendly manifest yaml files will be pushed to. On GitHub create a new repository. 

Next, generate a [deploy key]() for your new repository on GitHub. Keep the contents of yor public SSH key and local path to your private SSH key present for the next step.

### Create a Flux enabled AKS Cluster
Use the content of your public SSH key and path to your private SSH key when following the directions for cluster set up [here](https://github.com/Microsoft/bedrock/tree/master/cluster).


## Create HLD Repository
### Using GitHub to host your git repositories
In order to get started a [high level deployment definition]() (HLD) repo is needed. We provide a sample GitHub repo [here]() that you can fork.

 In order to access the destination respository we need appropriate authentication. Create a GitHub Personal Access Token if you don't have one already. Instructions can be found [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).

## Creating an Azure DevOps Pipeline
Configuration of an Azure Dev Ops [build]() is necessary. We provide a YAML configration file in the sample HLD repository that performs the following behaviors:

+ On a pull request (pre push to master) will execute a simple validation on proposed changes to infrastructure definition in the HLD repo.

+ On a merge to master branch (post push to master) we execute a script to transform the high level definition to YAML using [Fabrikate]() and push it to the manifest repository.

### Creating a Build pipeline
... _UI steps to point at HLD repo_ ...

### Setting environment variables in Azure DevOps
+ `accesstoken` this one should contain the GitHub personal access token and made secret.
+ `aks_manifest_repo` this one should contain the url to manifest repository in the format: `username/repo_name`.

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

## Make a Pull Request
1. Create a new branch in your HLD repo and make a commit to the high level definition such as ....
2. From GitHub perform pull request to merge your changes into master branch
3. Once checks has passed have the PR approved 

## Monitor Repository Changes=
Once a pull request is approved you can monitor the progress of the HLD transformation in the Build menu in your Azure DevOps _project_.

..._Show screenshot_... 

Once the build is successful navigate to your manifest repository. You see a very recent commit to the main branch.

## Monitor Cluster Changes
..._Instructions to monitor Flux pod logs_...



## Background
* Link to Azure Dev Ops Getting started
+ Link to bedrock main README
+ Link to GitHub Personal Access token creation

## TODO
+ Create instructions for using Azure DevOps git repositories
+ Instructions to use KubeDiff to monitor cluster state