# Creating GitHub Repos for Bedrock GitOps

## Instructions
## 1. Create Manifest Repository
You will also need a destination repository where the kubectl friendly manifest yaml files will be pushed to. On GitHub create a new repository. 

Next, generate a [deploy key]() for your new repository on GitHub. Keep the contents of yor public SSH key and local path to your private SSH key present for the next step.

## 2. Create a Flux enabled AKS Cluster
Use the content of your public SSH key and path to your private SSH key when following the directions for cluster set up [here](https://github.com/Microsoft/bedrock/tree/master/cluster).


## 3. Create HLD Repository
In order to get started a [high level deployment definition]() (HLD) repo is needed. We provide a sample GitHub repo [here](https://github.com/samiyaakhtar/aks-deploy-source) that you can fork.

 In order to access the destination respository we need appropriate authentication. Create a GitHub Personal Access Token if you don't have one already. Instructions can be found [here](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/).

## Reference
* https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github?view=azure-devops