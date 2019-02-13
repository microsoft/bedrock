# Azure DevOps Example
These instructions guide you through a GitOps workflow using Azure DevOps git repositories.

## Requirements
+ You belong to an Azure DevOps _organization_

## Instructions
Follow instructions to install the [Azure CLI DevOps Extension](https://github.com/Microsoft/azure-devops-cli-extension)

### 1. Create a new project in Azure DevOps via Azure CLI
Once installed create a project in Azure DevOps
```
$ az devops project create -n $PROJECT_NAME
```

Next, create high level deployment defintion and manifest repositories in your new ADO project
```
$ az repos create --name $HLD_REPO_NAME
$ az repos create --name $MANIFEST_REPO_NAME
```

Then, import a sample HLD repo to your ADO from a shared GitHub repos
```
$ az repos import create --git-source-url $SAMPLE_HLD_REPO_PATH --repository HLD_REPO_NAME
$ az repos import create --git-source-url $SAMPLE_MANIFEST_REPO_PATH --repository MANIFEST_REPO_NAME
```

The imported HLD example contains an Azure Pipelines yaml file that will activate checks on pull requests and merge to master branch. It will also import a `build.sh` script that the Azure Pipelines yaml file relies on. These processes are critical to maintaining the _release flow_.

### 2. Create an Azure DevOps Build Pipeline
To activate the above checks we must create an Azure DevOps _build_. 

In the Azure DevOps,
1. Click on "Pipelines" on the left side to expand a submenu
2. Click on "Builds" from the submenu
3. In the 2nd column from the left click the "+ New" button
4. Select "New build pipeline"
5. Choose "Azure Repos" as the selection to the "Where is your code?" prompt
6. Choose the repo that you named as $HLD_REPO_NAME

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

### 3. Configure Flux

Once you have your Azure DevOps repos in place and the Azure Pipelne Build working, you will need to configure Flux with the Manifest Repo. To do this, [Flux](https://github.com/weaveworks/flux/blob/master/site/get-started.md) has an easy-to-follow guide on setting this up. In summary,

1. Deploy Flux to an cluster by editing the `flux-deployment.yml` as necessary, and then running `kubectl apply -f deploy`
2. Generate an SSH key by running `fluxctl identity`.
3. Copy the SSH key.
4. In Azure DevOps, under your User Profile > Security > SSH public keys, click on `Add` and add the Flux deploy key.

Now, when a change is commited to the Manifest repo, Flux should acknowledge the commit and make changes to the state of your cluster as necessary. You can monitor Flux by viewing the logs by running `kubectl -n default logs deployment/flux -f` (or whichever namespace was specified for Flux at deployment, in this case Flux was deployed in the default namespace)

## Summary

## Outline of instructions (ignore)
- Instructions to create a build from the existing yaml in the UI
- Instructions to add public SSH key on Manifest repo (no api for this, UI work)
- Inform user to deploy a cluster with flux using the same public/private key
- Make a change to the HLD repo. 
- Make a pull request.
- Approve pull request
- See published changes in the Manifest repo
- Monitor the Flux logs 
- Alternatively check the kube diff metrics
