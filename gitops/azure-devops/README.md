# GitOps with Azure DevOps

Components of a GitOps workflow
<img src="PAT.svg?sanitize=true">

## Prerequistes 

* Have an existing _organization_ on [Azure DevOps](https://azure.microsoft.com/en-us/services/devops/)
* Create an Azure DevOps [project](https://docs.microsoft.com/en-us/azure/devops/organizations/projects/create-project?toc=%2Fazure%2Fdevops%2Fuser-guide%2Ftoc.json&%3Bbc=%2Fazure%2Fdevops%2Fuser-guide%2Fbreadcrumb%2Ftoc.json&view=azdevops&tabs=new-nav)

## Reproducing the Workflow

### Prerequisites (manual steps):
1. Source and Destination Git Repos must be created and defined.
(E.g. https://github.com/yradsmikham/walmart-hld/ (source) and https://github.com/yradsmikham/walmart-k8s/ (destination))
2. A Personal Access Token (PAT) will need to be generated on the destination repo
3. An AKS Cluster should already be up and running (this could be automated by the Infra team, but is a prereq for the purpose of this demo)
4. Azure DevOps Pipeline build that is configured to be triggered by the source Git repo, and will run a shell script. The azure-pipeline.yml file should look something like the following:


```# Starter pipeline
# Start with a minimal pipeline that you can customize to build and deploy your code.
# Add steps that build, run tests, deploy, and more:
# https://aka.ms/yaml
      
trigger:
- master
    
pool:
  vmImage: 'Ubuntu-16.04'
    
steps:
- checkout: self
  persistCredentials: true
  clean: true
    
- task: ShellScript@2
    inputs:
      scriptPath: cicd/build_pat.sh
    env:
      ACCESS_TOKEN: $(ACCESS_TOKEN)
```

The PAT will be configured as an encrypted secret variable consumed by the script.
5.  Deploy key created for Flux must be configured in destination repo. Flux should be configured and installed on AKS cluster.

### Automation:
1. The source repo should contain high level definition files, the azure-pipelines.yml, and the shell script that is operated by Azure DevOps Pipelines. Changes made to the component.json file will be made as a commit to the Git Repo.
2. Every commit that comes through will trigger Azure Pipelines Build, which executes the shell script.
3. The shell script will download, install, run Fabrikate, and push any updates made to the AKS manifest files to the destination repo
4. Updates made to manifest files will be detected by Flux (which is installed on the AKS cluster), and changes will be reflected in the AKS cluster.

