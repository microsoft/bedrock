# Octopus Deploy: Container Image Tag Release Pipeline

In addition to the [manifest generation pipeline](https://github.com/Microsoft/bedrock/blob/master/gitops/azure-devops/ManifestGeneration.md), Octopus Deploy can help extend the pipeline by providing a way for container promotion.

If you are new to Octopus Deploy, we **strongly** recommend setting up the [manifest generation pipeline](OctopusDeploy.md) using Octopus Deploy first. This is because the guide will assume that you already have part of your Octopus Infrastructure (e.g. Deployment Targets, Target Statuses, Environments, etc.) in place.

This guide will assist you with constructing the following image tagging release pipeline:

![Image Tag Release Pipeline](images/image-tag-release-pipeline.png)

## Prerequisites

1. An _Octopus Server_ and an _Octopus account_. The [Azure Marketplace](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/octopus.octopusdeploy) supports Octopus Deploy under a 45-day free trial, and will serve as a good starting point for deploying your first Octopus Server. For more information on gettings started, please visit [here](https://github.com/Microsoft/bedrock/blob/master/gitops/octopus/OctopusDeploy.md#getting-started).
2. _High Level Deployment Description_: Either your own [Fabrikate](https://github.com/Microsoft/fabrikate) high level definition for your deployment or a sample one of ours.  We provide a [sample HLD repo](https://github.com/samiyaakhtar/aks-deploy-source) that builds upon the [cloud-native](https://github.com/timfpark/fabrikate-cloud-native) Fabrikate definition. The one used in this example can be found [here](https://github.com/yradsmikham/fabrikate-go-server).

## Setup

### 1. Create a new Octopus Project

Assuming this is not your first time using Octopus Deploy, let's start off by creating a new project.

![Create a new Octopus project](images/octo-create-new-proj.png)

![Name your project](images/octo-create-new-proj-2.png)

### 2. Define Deployment Process

You should be taken to the project page where you have the option to define your Deployment Process.

![Define Deployment Process](images/octo-define-process.png)

Add a `Script` step.

![Add Process](images/octo-process-script.png)

![Add a bash script](images/octo-add-script.png)

Create a step using a bash script called `Download Scripts`. The purpose of this step is to download the `build.sh` from the offcial [Microsoft/Bedrock](https://github.com/Microsoft/bedrock/blob/master/gitops/azure-devops/build.sh) repo.

You want to configure the execution location to run on each deployment target with a selected role (bash scripts cannot run on the Octopus Server). If you have not created a role before, you can create a new role by simply typing one in.

![Create a Download Script step](images/octo-download-scripts.png)

Next, under the Script section, select `Inline source code`, and paste in the following bash script:

```
# Download build.sh
curl https://raw.githubusercontent.com/Microsoft/bedrock/master/gitops/azure-devops/build.sh > build.sh
chmod +x ./build.sh
```

Again, this will download the `build.sh` from the Microsoft/Bedrock repo, which will be sourced in the next step.

![Inline source code](images/octo-download-scripts-2.png)

On the top right corner, click on `Configure Features`, which will provide a pop-up to enable specific features for the script. Select `Substitute Variables in Files` since the `build.sh` _does_ involve using environment variables. Then, click `OK`.

![Enable Features](images/octo-enable-features.png)

Do not forget to `Save` your step!

![Save](images/octo-save.png)

Navigate back to the Process page to add another Step.

![Add another Process Step](images/octo-add-another-step.png)

![Create another Release step](images/octo-run-release-step.png)

Again, you will add another bash script step, but instead the script will execute the following:

```
# Define Environment Variables
ACCESS_TOKEN_SECRET=#{ACCESS_TOKEN_SECRET}
REPO=#{REPO}
BRANCH=#{BRANCH}
COMMIT_MESSAGE=#{COMMIT_MESSAGE}
YAML_PATH=#{YAML_PATH}
YAML_PATH_VALUE=#{YAML_PATH_VALUE}
YAML_PATH_2=#{YAML_PATH_2}
YAML_PATH_VALUE_2=#{YAML_PATH_VALUE_2}
SUBCOMPONENT=#{SUBCOMPONENT}

# Reset Environment
rm -rf fab*

# Source build.sh
. build.sh --source-only

# Initialization
verify_access_token
init
helm init
get_os

# Fabrikate
get_fab_version
download_fab

# Clone HLD repo
git_connect

echo "FAB SET"
fab set --subcomponent ${SUBCOMPONENT} ${YAML_PATH}=${YAML_PATH_VALUE} ${YAML_PATH_2}=${YAML_PATH_VALUE_2}

echo "GIT STATUS"
git pull origin master
git status
git fetch

echo "GIT ADD"
git add -A

# Set git identity
git config user.email "admin@azuredevops.com"
git config user.name "Automated Account"

echo "GIT COMMIT"
echo "COMMIT MESSAGE: $COMMIT_MESSSAGE"
git commit -m $COMMIT_MESSAGE

echo "GIT PUSH"
git_push
```

![Source Inline](images/octo-run-release-inline.png)

Hit `Save`.

Project variables need to be specified in order for the scripts to run. For this pipeline, there are a few variables that are considered:

```
ACCESS_TOKEN_SECRET: the personal access token from your git repository

COMMIT_MESSAGE: custom message used when committing and pushing to git

OCTOPUS_API_KEY: the API key used to kick off a release in another project

OCTOPUS_SERVER: the Octopus Server's API endpoint

OCTOPUS_ENVIRONMENT: the environment to create the release in (must exist for the other project)

OCTOPUS_SPACE: the name of the space that the project resides in

OctopusUseRawScript: parameter that allows raw scripting to be used in the Deployment Target

REPO: the link to the HLD repo (e.g. https://github.com/yradsmikham/fabrikate-go-server)

BRANCH: the branch of the Fabrikate HLD repo (e.g. master)

SUBCOMPONENT: the subcomponent within your Fabrikate HLD that should be manipulated

YAML_PATH: the yaml path to the subkey to set (e.g. data.replicas)

YAML_PATH_VALUE: the value to the subkey
```

**Note**: The personal access token is used to commit and push to the Fabrikate HLD repo. (This variable can be censored by right-clicking on the value column and changing the "type" to sensitive.)

**Note**: The API Key can be generated by going to your user Profile > My API Keys > New API Key. Enter a purpose and click `Generate New`.

**Note**: In Octopus Deploy, variables cannot have values that contain spaces or special characters. Thus, the `COMMIT_MESSAGE` must be a single string or if using spaces and/or special characters, you will need to hardcode the message in the inline source code.

**Note**: It is important to enable [Raw Octopus](https://octopus.com/blog/trying-raw-octopus), or "Raw Scripting" for this pipeline because it is a default configuration to have deployments run [Calamari](https://octopus.com/docs/api-and-integration/calamari) when using Octopus Deploy, and this will interfere with "resetting" the Deployment Target. For this reason, raw scripting is used to allow the script steps to execute directly through the opened SSH connection without any extra wrapping or bootstrapping that comes naturally with Octopus. To do this, it is important to add the variable `OctopusUseRawScript` and set it to `True`.

**Note**: The `fab set` command allows you to specify as many yaml path values as needed. In this example, we have set two examples: (1) image repository, and (2) image tag. This will translate to: `image.repository=saakhtaregistry.azurecr.io/jackson-ui` and `image.tag=v0.2`. Notice that the variable `YAML_PATH_VALUE` is configured to be a [prompted variable](https://octopus.com/docs/deployment-process/variables/prompted-variables), which means that the variable is not known, and the value for the variable will be provided during the Release time. However, in situations where the value is not provided during the Release deployment, then the default value of `v0.2` will be used.

![Variables](images/octo-release-variables.png)

**OPTIONAL** (please proceed if you already have a [manifest generation pipeline](https://github.com/microsoft/bedrock/blob/master/gitops/octopus/OctopusDeploy.md) in place): Navigate to the Process page again to add one last step. Like the previous steps, include a bash script,  and use the following inline source code:

```
# Define Environment Variables
OCTOPUS_SERVER=#{OCTOPUS_SERVER}
OCTOPUS_API_KEY=#{OCTOPUS_API_KEY}
OCTOPUS_ENVIRONMENT=#{OCTOPUS_ENVIRONMENT}
OCTOPUS_SPACE=#{OCTOPUS_SPACE}

# Download octo.exe
wget https://download.octopusdeploy.com/octopus-tools/6.2.3/OctopusTools.6.2.3.linuxmint.17-x64.tar.gz
tar xvzf OctopusTools.6.2.3.linuxmint.17-x64.tar.gz
rm OctopusTools.6.2.3.linuxmint.17-x64.tar.gz
chmod +x ./Octo

# Initiate HLD to Manifests Release
./Octo create-release --project "hld to manifests" --deployto $OCTOPUS_ENVIRONMENT --server $OCTOPUS_SERVER --apiKey $OCTOPUS_API_KEY --space $OCTOPUS_SPACE
```

![Initiate HLD to Manifests Releast](images/octo-hld-manifest.png)

This optional step is useful for kicking off another Octopus Release, specifically the [manifest generation pipeline](https://github.com/microsoft/bedrock/blob/master/gitops/octopus/OctopusDeploy.md). [Automatic release creation](https://octopus.com/docs/deployment-process/project-triggers/automatic-release-creation) is supported in Octopus, but only if you are uploading specific packages (e.g. NuGet).

### 3. Create and Deploy Release

You're now at the point to create and deploy a Release! Navigate to `Releases` on the left side panel and click on `Create Release`.

![Create a Release](images/octo-create-release.png)

This is optional, but you can specify notes for the Release.

![Add Release Notes](images/octo-release-notes.png)

Be sure to click `Update Variables` to ensure that your environment variables exist. It is important to note that if changes are made to the Project Variables, you will need to update the variables in the Release snapshot before deploying.

![Release Snapshot](images/octo-release-snapshot.png)

When you are finished, click `Deploy`, and this will deploy to environments that you have specified.

![Prepare to Deploy](images/octo-deploy.png)

Your deployment should be in progress now.

![Deployment in Progress](images/octo-deploying.png)

You can track the progress of your deployment and view logs on the `Task Log` tab.

![View Tasks Logs](images/octo-task-logs.png)

### 4. Promotion

When your Release runs successfully, you have the option to promote to the next environment (e.g. qa).

![Deploy to QA](images/octo-deploy-to-qa.png)

![Deploy to QA](images/octo-qa-deploy.png)

**Note**: You will need to prepare your `qa` environment before deploying if you have not already done so. This means that you should have Deployment Targets specified and labeled `qa` if used in your `qa` environment.

![](images/octo-dep-targets-qa.png)

## TeamCity

The TeamCity [image tag release](https://github.com/microsoft/bedrock/blob/master/gitops/teamcity/ImageTagRelease.md) pipeline works hand in hand with this Octopus pipeline. When you do have a TeamCity pipeline setup, it is worth visting how to [trigger Octopus from TeamCity](https://github.com/microsoft/bedrock/blob/master/gitops/teamcity/ConnectToOctopus.md). With the [manifest generation pipeline](https://github.com/microsoft/bedrock/blob/master/gitops/octopus/OctopusDeploy.md), you should be able to complete the entire GitOps CI/CD workflow using TeamCity and Octopus Deploy.
