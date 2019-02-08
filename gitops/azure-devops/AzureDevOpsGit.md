## Requirements
+ You belong to an Azure DevOps _organization_

## Instructions
Follow instructions to install the Azure CLI DevOps Extension [here](https://github.com/Microsoft/azure-devops-cli-extension)

Once installed create a project in Azure DevOps
```
$ az devops project create -n $PROJECT_NAME
```

Next create high level deployment defintion and manifest repositories in your new ADO project
```
$ az repos create --name $HLD_REPO_NAME
$ az repos create --name $MANIFEST_REPO_NAME
```

Next import a sample HLD repo to your ADO from a shared GitHub repos
```
$ az repos import create --git-source-url $SAMPLE_HLD_REPO_PATH --repository HLD_REPO_NAME
$ az repos import create --git-source-url $SAMPLE_MANIFEST_REPO_PATH --repository MANIFEST_REPO_NAME
```

The imported HLD example contains an Azure Pipelines yaml file that will activate checks on pull requests and merges to master branch. These processes are critical to maintaining the _release flow_.

To activate the above checks we must create an Azure DevOps _build_. 

In the Azure DevOps
1. Click on "Pipelines" on the left side to expand a submenu
2. Click on "Builds" from the submenu
3. In the 2nd column from the left click the "+ New" button
4. Select "New build pipeline"
5. Choose "Azure Repos" as the selection to the "Where is your code?" prompt
6. Choose the repo that you named as $HLD_REPO_NAME

At this point your will see the YAML for azure-pipeline.yml which is contained in the HLD repo.
1. Click the blue run button on the right side.
2. You should see the outoput of an azure pipeline but instead of waiting for teh build to finihs 
3. Click the ellipsis (...) in teh upper right corner and choose "Edit pipeline"
4. You will see the YAML contents again. 
5. Click on the ellipsis to teh right of teh blue "Run" button and choose "Pipeline settings"
6. Click the "Variables" tab 
7. Add two variables:
    1. __Name__ AKS_MANIFEST_REPO __Value__ MANIFEST_REPO_NAME_GIT_URL
    2. __Name__ ACCESS_TOKEN __Value__ MANIFEST_REPO_NAME_GIT_URL

**CAVEAT**: Since we own the destination repo there are easier ways to do auth here! Let's see how our shell script has changed to support ADO

Afterward hit "Save & Queue"
You will see the build run and hopefully complete successfully
At this point we can make a PR change to the HLD repo



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