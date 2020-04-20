# Walkthrough: Service Management

One the most common activities a modern service team performs is deploying and updating a particular service -- or set of services. This walkthrough will cover onboarding and deploying an initial version of the service in the cluster using the automation available in Bedrock.

This workflow centers around the repositories that hold application code, associated Dockerfile(s), and helm deployment charts in conjunction with the high level definition repo we have already established. We do not take a very opinionated view of how these repositories are structured: they can hold one (single service) or more (monorepository) service depending on your source control methodology.

## Prerequisites
1. Completion of the [First Workload guide](./docs/firstWorkload/README.md) to setup an AKS cluster configured with flux.
2. Completion of the [GitOps Pipeline Walkthrough](./docs/hld-to-manifest.md) to set up required GitOps workflow repositories and pipelines.

## Onboarding a Service Repository

Note: Our automation currently only supports Azure Devops and Azure Devops Repos.

In this walkthrough, we'll use the [Azure Voting App](https://github.com/Azure-Samples/azure-voting-app-redis) as an example service that we are deploying, but you can also swap in your own service.

1. If you don't have an existing source code repository, [create one in the given Azure Devops Project](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops#create-a-repo-using-the-web-portal)
2. [Clone this repository to your local machine](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-new-repo?view=azure-devops#clone-the-repo-to-your-computer)

Our automation distinguishes between a `project` and a `service`. A `project` in Bedrock terminology is the same as a git repo, which contains one or more `services`.

### Onboarding a Service Project

Navigate to the root of the `project` (for the Azure Voting App example application, this is the root directory) and run the `project init` command:

```sh
$ spk project init
$ git add -A
$ git commit -m "Onboarding project directory"
```

This creates a `bedrock.yaml` file that maintains the set of `services` that are part of this `project`.

It also creates a `hld-lifecycle.yaml` Azure Devops definition that manages the lifecycle of this `project` in the high level definition.

Finally, it creates a `maintainers.yaml` file with a list of the named maintainers of the project.

### Creating the Lifecycle Pipeline

We next want to create the lifecycle pipeline for our `project` which automatically manages adding services (and in advanced scenarios, rings) to our high level deployment definition.

The first step to do that is to create a common variable group in Azure Devops that contains a set of secrets that we will use in our pipeline:

```sh
# If you're coming from the infrastructure deployment guides mentioned in
# https://github.com/microsoft/bedrock#infrastructure-management you can reuse
# the service principal values saved in sp.json via:
$ export SP_TENANT=$(cat ~/cluster-deployment/sp/sp.json | jq -r .tenant)
$ export SP_APP_ID=$(cat ~/cluster-deployment/sp/sp.json | jq -r .appId)
$ export SP_PASS=$(cat ~/cluster-deployment/sp/sp.json | jq -r .password)

# With all of $ACR_NAME $SP_APP_ID $SP_TENANT $SP_PASS set:
$ export VARIABLE_GROUP_NAME=voting-app-vg
$ spk project create-variable-group $VARIABLE_GROUP_NAME -r $ACR_NAME -u $SP_APP_ID -t $SP_TENANT -p $SP_PASS
$ git add -A
$ git commit -m "Adding Project Variable Group."
$ git push -u origin --all
```

where `ACR_NAME` is the name of the Azure Container Registry for the project, `SP_APP_ID` is the service principal's id,
`SP_PASS` is the service principal's password, and
`SP_TENANT` is the service principal's tenant. This service principal is expected to have read and write access to the Azure Container Registry.

This creates the variable group with Azure Devops and also adds it to our `bedrock.yaml` and `hld-lifecycle.yaml` such that it will be used by the pipeline.

With this created, we can deploy the lifecycle-pipeline itself with:

```sh
$ spk project install-lifecycle-pipeline --org-name $ORG_NAME --devops-project $DEVOPS_PROJECT --repo-url $VOTING_APP_REPO_URL --pipeline-name $PIPELINE_NAME
```

where `ORG_NAME` is the name of the Azure Devops org, `DEVOPS_PROJECT` is the name of your Azure Devops project, `SOURCE_REPO_URL` is the git url that you used to clone your application from Azure Devops, and `PIPELINE_NAME` is the name of the pipeline (eg. `azure-voting-app-pipeline` in the case of our sample) that you'd like to create.

Note: If you are using a repo per service source control strategy you should run install-lifecycle-pipeline once for each repo.

Once this lifecycle pipeline is created, it will run and create a pull request on your high level definition that adds the `project` as a component to your root.  Go to your high level definition repo and accept that pull request.

## Onboarding a Service

With that, we have set up all of the pipelines for the project itself, so let's onboard our first service.

We can do that with `spk service create` which, like all of the spk service and project commands, runs from the root of the repo.  In this case, `azure-vote` refers to the path from the root of the repo to the service.

```sh
$ spk service create azure-vote \
    --display-name azure-voting-app \
    --helm-config-git https://github.com/mtarng/helm-charts \
    --helm-config-path chart-source/azure-vote \
    --helm-config-branch master
```

For more custom Dockerfiles that may require passing in arguments as build variables, please visit [here](https://github.com/microsoft/bedrock-cli/blob/master/guides/project-service-management-guide.md#passing-variables-as-dockerfile-build-arguments).

As part of service creation, we need to provide to SPK what we want it to deploy in the form of a helm chart. This helm chart is largely freeform, but requires the following elements in its `values.yaml` such that Bedrock can deploy new builds.

```yaml
image:
  tag: latest
  repository: some.acr.io/repo
serviceName: "fabrikam"
```

Once completed, `service create` will add the service to your `bedrock.yaml` file for the `project` and add a `build-update-hld.yaml` Azure Devops file to your `service`.

For this first walkthrough, we are not going to utilize the more advanced ring management functionality that Bedrock provides, so we need to make a small edit to our bedrock.yaml file.  After the `displayName` line, add `disableRouteScaffold: true` to prevent scaffolding of ring routing:

```yaml
rings:
  master:
    isDefault: true
services:
  - path: ./azure-vote
    disableRouteScaffold: true
    displayName: azure-voting-app
    helm:
      chart:
        accessTokenVariable: ACCESS_TOKEN_SECRET
        branch: master
        git: 'https://github.com/mtarng/helm-charts'
        path: chart-source/azure-vote
    k8sBackend: ''
    k8sBackendPort: 80
    middlewares: []
    pathPrefix: ''
    pathPrefixMajorVersion: ''
```

Then commit all of these files and push them to your Azure Devops repo:

```sh
$ git add -A
$ git commit -m "Onboard voting-app service"
$ git push origin master
```

This addition to the project `bedrock.yaml` will cause the project's lifecycle pipeline to trigger. Once the pipeline runs to completion, it will open a Pull Request against the HLD (high-level-definition) repository. Merge this Pull Request to add the new service component to the HLD. Note that the service may not have a container for the cluster to pull until the build pipeline is installed and run; the next steps will cover this work.

Our final step is to create the source code to container build pipeline for our service.  We can do that with:

```sh
$ spk service install-build-pipeline azure-vote -n azure-vote-build-pipeline -o $ORG_NAME -u $VOTING_APP_REPO_URL -d $DEVOPS_PROJECT
```

This should create the build pipeline and build the current version of your service into a container using its Dockerfile.  It will then create a pull request on the HLD repo for this new image tag.

Merge this PR and the HLD to Manifest pipeline will trigger. Once this pipeline completes, the azure-voting-app application will be deployed into your cluster via flux.
