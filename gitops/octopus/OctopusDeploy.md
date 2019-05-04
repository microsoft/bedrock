# Octopus Deploy

Octopus Deploy, an automated deployment and release management tool, has been tested against the Bedrock GitOps workflow. It is supported in the [Azure Marketplace] (https://azuremarketplace.microsoft.com/en-us/marketplace/apps/octopus.octopusdeploy) with a free 45-day trial. This guide will assist in getting you started on installing, configuring, and deploying a Release on an Octopus Server (hosted in Azure) that is modeled after the following example of [manifest generation pipeline](../azure-devops/ManifestGeneration.md)


![GitOps Workflow using Octopus Deploy](images/gitops-octopus-deploy.png)


## Getting Started

### 1. Launch an Octopus Deploy Server in Azure Portal

1. Create an Octopus Deploy instance in Azure Portal

![Octopus Deploy in Azure Portal](images/create-octopus-deploy.png)

![Configure Infrastructure Requirements for Octopus Deploy](images/create-octopus-deploy-2.png)

![Configure Octopus Deploy](images/create-octopus-deploy-3.png)

The following resources should populate in the resource group when Octopus Deploy is successfully deployed in Azure.

![Octopus Deploy Resources in Azure](images/octopus-deploy-resources.png)

### 2. Login to your Octopus account

1. To access the Octopus Deploy server, you will need to find the DNS name of of the `octopus-publicip` resource.

![Octopus Public IP](images/octopus-public-ip.png)

You can access the Octopus Server via browser using the DNS name. Once there, login with the credentials that were used upon creation of the Octopus server (e.g. Octopus Deploy Administrator Credentials).

### 3. Create and prepare your Deployment Target resources

1. Create a Linux Virtual Machine in Azure. You can do this via the Azure CLI or in Azure Portal. To use Azure CLI, run the following command:

```
az vm create \
  --resource-group "myResourceGroup" \
  --name "otco-vm" \
  --image "UbuntuLTS" \
  --admin-username "yradsmik" \
  --admin-password "U$e@StrongPassword" \
  --location local
```
Change the arguments to something that is appropriate for your environment.

2. Use SSH to connect to the virtual machine

    `ssh admin-username@publc-ip-address`

You may be prompted to enter the admin password.

3. Run shell as a target user by executing the command `sudo -s`.

This will allow you to run as the `root` user which will give you the appropriate permissions to download packages that are required for the pipeline.

4. Install necessary components for GitOps workflow:

You will need to install git, zip, and libunwind-dev. In addition, you will also need to download, install, and initialize Helm. You can do this by running the following commands:

```
apt-get update
apt-get install -y git zip libunwind-dev

# Helm
curl -LO https://git.io/get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
helm init
```

5. Clone HLD repository

Clone your HLD git repo to the $HOME directory of your VM by running `git clone <Link to HLD Repo>`. Depending on how your HLD repo is structured, you may need to copy the contents of your HLD repo to the $HOME directory. You can do this by

   `cp -r <name of HLD repo>/* .`

### 4. Create your Octopus Release

1. Create an environment(s) for your Release (e.g. `dev`, `qa`, `prod`).

![Create a `dev` environment](images/octopus-create-env.png)

2. Add Deployment Targets to your Infrastructure.

![Add an SSH connection for Linux Deployment Target](images/add-deployment-target.png)

Specify the public IP address of the Linux VM.

![SSH Connection](images/ssh-connection.png)

If you have never added an account before, click on the option to add a new account and select "Username/Password". You may also use SSH Key Pair if an SSH Key was used to create the VM as opposed to a username and password.

![Add Account to use during deployment](images/octopus-add-account.png)

Enter the credentials for the VM username and password and choose the appropriate environment for it to be used in.

![Create account for the Linus VM](images/octo-create-account.png)

Select the environment that was created in Step 1, and create a new Target role (e.g. `octo-admin`). If a target role does not already exist, add a new role.

![Choose environment and target role](images/octo-choose-env-role.png)

Be sure to select the name of the Username/Password account that was created earlier.
![Deployment Target Communication Section](images/octo-deploy-target-communication.png)

3. Check the health of the Deployment Target(s)

Under Connectivity, there is the option to see the connection health of your VM.
![Check Health of Deployment Target](images/octo-deploy-target-health1.png)

Be sure that the connection health is in good standing before deploying your Release.
![Check Health of Deployment Target Connectivity](images/octo-deploy-target-health2.png)

4. Define your deployment process.

Add a new step that will call a bash script. In this section, you will use the `build.sh` script from [Microsoft/Bedrock](https://github.com/Microsoft/bedrock/blob/master/gitops/azure-devops/build.sh). This `Inline Source Code` should do a few things: (1) define Environment Variables that are translatable in Octopus Deploy (2) ensure that the Deployment Target is "reset" for the Release deployment by removing all Fabrikate remnants from previous runs (3) download the `build.sh` and execute it.

```
#!/bin/bash

#Define Environment Variables

ACCESS_TOKEN_SECRET=#{ACCESS_TOKEN_SECRET}
REPO=#{REPO}
BRANCH=#{BRANCH}
COMMIT_MESSAGE=#{COMMIT_MESSAGE}

# Remove Fabrikate
rm -rf fab*

# Download build.sh
curl https://raw.githubusercontent.com/Microsoft/bedrock/master/gitops/azure-devops/build.sh > build.sh
chmod +x ./build.sh
. build.sh
```

Under `Variables`, be sure to define the variables as shown:

![Define Project Variables](images/octo-env-variables.png)

It is important to enable [Raw Octopus](https://octopus.com/blog/trying-raw-octopus), or "Raw Scripting" for this pipeline because it is a default configuration to have deployments run [Calamari](https://octopus.com/docs/api-and-integration/calamari) when using Octopus Deploy, and this will interfere with "resetting" the Deployment Target. For this reason, raw scripting is used to allow the script steps to execute directly through the opened SSH connection without any extra wrapping or bootstrapping that comes naturally with Octopus. To do this, it is important to add the variable `OctopusUseRawScript` and set it to `True`.

### 5. Deploy

Create a Release for deployment!

![Create a new Release](images/octo-release1.png)

![Specify version and release notes](images/octo-release2.png)

![Deploy to specific environment](images/octo-release3.png)

![Deploy!](images/octo-release4.png)

### Check Octopus Deploy Logs

After your Release is finished running, you can view the results and logs of the Release.

![A Successful Octopus Deployment](images/octo-successful-deploy.png)

![Octopus Deploy Release Logs](images/octo-release-logs.png)

**NOTE**: The Fabrikate logs along with other logs from `build.sh` will show up as error logs in Octopus Deploy. This is miscontrued.

## Challenges with Octopus Deploy

- There is **less automation** when using Octopus Deploy in place of Azure DevOps.
    - Octopus Deploy requires that users provide their own resources, or Deployment Targets. Even though this could most likely be automated _outside_ of Octopus, this is still an additional step that is mandatory.
- There is no support for GitHub triggers.
    - This is the reason why cloning your HLD repo in advance was required as part of preparing your Deployment Targets.
    - In Azure DevOps, the ability to link your build and release pipelines to git repositories allow them to have access to the the resources without needing to clone them.
    - This also becomes problematic when automating a build or release when there are new commits made to the source repo. The closest thing to triggered releases is configuring scheduled releases in Octopus.
- Octopus currently does not allow users to build custom plugins or extensions.
    - This makes it difficult for users or organizations who want to have a more custom CI/CD workflow.
