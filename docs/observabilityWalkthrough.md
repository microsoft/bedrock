# Observability in Service Deployments

Many Kubernetes deployments are composed of not just one, but many microservices, and this complexity is compounded by, for latency, scalability, and/or reliability concerns, that these microservices are often also deployed across multiple clusters as well.  This makes it hard to reason about the current state of any individual cluster -- and especially a collection of ones that all together constitute the workload.

To help with this, Bedrock has a service introspection tool to provide better visibility the end to end deployment workflows. It integrates with the GitOps pipeline and service management that were setup in previous walkthrough guides. 

The service introspection tool exists in two forms:
1. Command line tool
2. Web Dashboard

The service introspection tool provides views into the current status of any change in the system, from continuous integration build to tracking the deployment of the container containing that commit in each of the downstream clusters consuming that container.

The service introspection main components are:
1. A Bedrock GitOps pipelines workflow. Currently supported in Azure DevOps
2. An Azure Storage Table
3. Service introspection command line tool and web dashboard

The following diagram shows how the introspection tool integrates with the Azure DevOps pipelines in a Bedrock GitOps Workflow.
![Service Introspection Tool](images/service-introspection-tool.png)

The Web Dashboard is shown in the image below. In Bedrock, the status is displayed from newest to oldest, and we can see in the first line that a commit has triggered a container build that is currently deployed in the west cluster but that the east cluster hasn't yet been synchronized and is currently still running the previous version of the container.

![Web Dashboard](images/service-introspection-dashboard.png)

This walkthrough will cover how to set up introspection in your own deployments and how to use it to observe changes to your cluster.

## Prerequisites
This guideline assumes you have completed the following:

1. Set up GitOps. Guideline: [A First Workload With Bedrock](./firstWorkload/README.md)
2. Set up the HLD to Manifests pipeline. Guideline: [Setting up an HLD to Manifest pipeline](hldToManifestWalkthrough.md)
3. Onboard a Service Repository. Guideline: [Service Management](services.md)


## Setup an Azure Storage Table
Service introspection tool needs a database to store the information about your
pipelines, builds and deployments. Currently, service introspection supports
storage in the form of an Azure Storage table. Follow the steps below to create
it or use an existing one.

### Create an Azure storage account

**Option 1:**

Use the
[`spk deployment onboard`](https://github.com/CatalystCode/spk/blob/master/docs/service-introspection.md#onboard)
command.

**Option 2:**

Create the account manually or use an existing storage account. You will need to
have the following properties of this storage before proceeding as they are
required to configure:

- Name of the storage account
- Access key to this storage account
- Table name (this is the table that will store Spektate introspection details)

Once you have a storage account with a table, you may proceed to start updating
the pipelines to send data to Spektate storage.

**Note:** The Azure storage account is needed to store information about your
pipelines and services that is displayed by service introspection.

### Create a table
Follow these
[instructions](https://docs.microsoft.com/en-us/azure/storage/tables/table-storage-quickstart-portal).

### Storage account CORS settings

Configure the CORS settings for the storage account to allow requests from the
service introspection dasbhoard.

1. Go to the [Azure portal](https://portal.azure.com)
2. Search for the name of your storage account
3. Click the CORS options on the menu on the left side:

![cors menu option](./images/cors-menu.png)

Add the following settings under **Table Service**:
![cors settings](./images/cors-settings.png)

**Note:** If you are running the service introspection spk dashboard in a port
other than `4040`, add that entry in the settings instead.

## Configure the Pipelines
The Bedrock GitOps pipelines need to be configured to start sending data to
`spk` service introspection. If you followed the guidelines from the (Prerequisites)[#prerequisites] each pipeline `yaml` will already have the script needed for introspection.

To send data from Azure pipelines to the Azure Storage table created
previously, a variable group needs to be configured in Azure DevOps (where the
pipelines are).

Create the following `introspection-values.yaml` file with the variables:
```
name: "introspection-vg"
description: "Service introspection values"
type: "Vsts"
variables:
    INTROSPECTION_ACCOUNT_KEY:
        value: "Set this to the access key for your storage account"
        isSecret: true
    INTROSPECTION_ACCOUNT_NAME:
        value: "Set this to the name of your storage account"
    INTROSPECTION_PARTITION_KEY:
        value: "This field can be a distinguishing key that recognizea your source repository in the storage for eg. in this example, we're using the name of the source repository `hello-bedrock`"
    INTROSPECTION_TABLE_NAME:
        value: "Set this to the name of the table you created previously in [Create a table](#create-a-table)"
```

To configure the variable group run:

```
$ spk variable-group create --file introspection-values.yaml --org-name $ORG_NAME --devops-project $DEVOPS_PROJECT --personal-access-token $ACCESS_TOKEN
```

Where `ORG_NAME` is the name of the Azure Devops org, `DEVOPS_PROJECT` is the name of your Azure Devops project and `ACCESS_TOKEN` is the Personal access token associated with the Azure DevOps org. In [Setting up an HLD to Manifest pipeline](hldToManifestWalkthrough.md) we created a personal access token. 
