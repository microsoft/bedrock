## Image Tag Release Pipeline

The guide below demonstrates how to deploy an instance of TeamCity on your Azure cloud to run continuous integration builds to build an ACR image for a sample application. 

![](./images/acr-diagram.png)

In order to connect this CI pipeline with a CD pipeline in Octopus Deploy, follow the steps [here](./ConnectToOctopus.md).

1. Login to [Azure Marketplace](https://ms.portal.azure.com/#blade/Microsoft_Azure_Marketplace/GalleryFeaturedMenuItemBlade/selectedMenuItemId/home) and search for TeamCity. 
Click on `TeamCity` > `Create`

    ![](./images/search_marketplace.png)

2. Configure settings for the TeamCity server by entering an appropriate name, selecting (or creating a new) resource group and location, and press `OK`.

    ![](./images/configure_basic_settings.png)

3. Configure settings for the Virtual Machine by entering an appropriate username and a strong password. Make sure to select a subnet and domain name label (it should be automatically filled in). Press `OK` to proceed.

    ![](./images/virtual_machine_settings.png)

4. Enter a strong password for MySEL and make sure a storage account is selected or automatically filled in. Press `OK` to proceed. 

    ![](./images/mysql_settings.png)

5. It should show a summary of all the settings about to be applied. Press `OK` to continue. 

    ![](./images/summary.png)

6. In this step it will prompt you for any payments, if needed. Agree to the terms of conditions and press `Create`. 

7. Click on the notification that says `Deployment in progress` and you can view the status of your deployment which is underway. Wait till this deployment is complete, then navigate to the `Outputs` tab on the left column. 

    ![](./images/deployment_inprogress.png)

8. When deployment is complete, the `Outputs` tab will give you a URL where TeamCity is deployed and the ssh command. Copy the `teamcityURL` and open it in the browser on another tab. 

    ![](./images/output_available.png)

9. When you visit this URL, for example `http://server-teamcity-999608bafa.eastus2.cloudapp.azure.com/showAgreement.html`, it will display the licence agreement for JetBrains TeamCity. Press `Accept` and `Continue`. 
10. Next, it will prompt you to create a new administrator account. Enter a username and secure password, then press `Create Account`. 

    ![](./images/create_admin_account.png)

11. Next, it will prompt you to fill in your profile. Complete your profile and navigate to `Projects` in the top left. It should display an option to Create a project. 

    ![](./images/create_project.png)

12. Enter the project details for your application code repository and enter credentials if it's not a public repository. In this example, we're using the app code repository for [Project Jackson](https://github.com/catalystcode/containers-rest-cosmos-appservice-java) which is a simple application with front and back end capabilities. 

    ![](./images/create_project_app_code.png)

13. Enter an appropriate name for the project build configuration and click `Proceed`. 
    ![](./images/create_project_from_catalyst_code.png)

14. At this step, it will start auto-detecting build steps found in the repository. If your Dockerfile works standalone without any parameters, select it in the checkboxes. We're going to leave all these unchecked since we will use a custom script and variables for security, to push these to the ACR image. Click on `configure build steps manually`.

    ![](./images/use_none.png)

15. In this step, we will manually add the command line script to build the ACR image. Paste the following lines of code:

    ```
    docker build -t $ACR_SERVER/jackson-api:v$ACR_CONTAINER_TAG .
    docker login $ACR_SERVER -u $ACR_USERNAME -p $ACR_PASSWORD
    docker push $ACR_SERVER/jackson-api:v$ACR_CONTAINER_TAG
    ```

    ![](./images/docker_api_create_configs.png)

16. Press `Save` and click on `Parameters` on the left column. 
    ![](./images/parameters_find.png)

17. Add the following parameters to the environment variables section:
    - `env.ACR_CONTAINER_TAG`: This is the tag for the ACR image, ideally it should contain useful information about the image, such as the build number, commit and branch name. Follow guide [below](#creating-an-acr-container-tag-with-branch-name-commit-hash-and-build-number) to create a tag containing this metadata, for simplicity you may set this to any number. 
    - `env.ACR_PASSWORD`: The password for the container registry. Set this to the password spec for security purposes.
    - `env.ACR_SERVER`: URL for the ACR server, for example we are using `saakhtatestregistry.azurecr.io`
    - `env.ACR_USERNAME`: The username for the container registry

    ![](./images/env_variables_acr.png)

18. Click on `Run` to do a test run for this configuration. You should be able to see a new tag show up in the ACR registry for the newly pushed image! 
19. If you would like to configure the same for the UI working directory, follow the same steps above but for a new build step, and paste the code below:

    ```
    docker build -t $ACR_SERVER/jackson-ui:v$ACR_CONTAINER_TAG .
    docker login $ACR_SERVER -u $ACR_USERNAME -p $ACR_PASSWORD
    docker push $ACR_SERVER/jackson-ui:v$ACR_CONTAINER_TAG
    ```

    Make sure the working directory is set to the UI folder correctly. 

20. Click on `Run` to do a test run for this configuration. You should now see both tags being built (if there are changes) and the new tag should show up in the ACR portal for UI! 
    ![](./images/acr_published_done.png)

21. (*Optional*) If you would like to trigger Octopus Deploy from this image tag release in TeamCity, follow the guide [here](./ConnectToOctopus.md). 


## Creating an ACR Container tag with branch name, commit hash and build number

It's a good practice to capture details about the commit and branch in the container tag, so we would like to use a tag with format `build_number-branch_name-short_commit_hash`, for example `24-master-3fb425c`. To achieve this, set this variable `ACR_CONTAINER_TAG` to `%env.BUILD_NUMBER%-%env.BRANCH_NAME%-%env.GIT_HASH%`. This assumes the following variables are defined:
- `BUILD_NUMBER`: This env variable should be set to `%build.number%`
- `BRANCH_NAME`: This env variable should be set to `%teamcity.build.branch%`, note that in order for this variable to work, you need to have the VCS build specification include at least one branch, read more [here](https://stackoverflow.com/a/27829516). 
- `GIT_HASH`: For now, set this variable to `%build.vcs.number%` which is the full commit hash, in a later step we will extract the short commit hash from the full hash. 

Next, we need to extract short hash from full commit hash. Create a new build step, set it to Custom script and add the code below:

```
shorthash="$(echo $GIT_HASH | cut -b 1-7 )"
echo "##teamcity[setParameter name='env.GIT_HASH' value='$shorthash']"
echo "Updating Git hash to $shorthash"
```

![](./images/git_hash_step.png)

This script gets a substring of the git hash and updates the environment variable in TeamCity for the next build steps to use. **Important**: Make sure this step is bumped to be the first step in the pipeline. 
