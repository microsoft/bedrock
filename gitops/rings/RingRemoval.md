# Ring Removal

The Ring removal process is an automated approach that reuses components from the [Bedrock CI/CD](https://github.com/microsoft/bedrock/tree/master/gitops) to remove a Ring resource from your Kubernetes cluster. It involves a _separate_ workflow in addition to the Bedrock CI/CD and is recommended as part of the [Rings Implementation](./RingsImplementation.md).

# Prerequisites

1. Azure DevOps Build Pipelines for [Manifest Generation](https://github.com/microsoft/bedrock/blob/master/gitops/azure-devops/ManifestGeneration.md)

# Setup

To create the Ring removal pipeline, you will need to create a new Azure DevOps Build pipeline that will use the `remove-ring.yml` shown below:

```bash
trigger: none

pr: none

jobs:
- job: RingRemoval
  displayName: ring_removal
  timeoutInMinutes: 90
  pool:
    vmImage: 'Ubuntu-16.04'
    timeoutInMinutes: 90
  steps:
  - script: |
      repo_url=$SRC_REPO
      repo_url="${repo_url#http://}"
      repo_url="${repo_url#https://}"
      git push "https://$ACCESS_TOKEN_SECRET@$repo_url" --delete $(Build.SourceBranchName)
    displayName: 'Delete Git Branch'
  - script: |
      # download build.sh from microsoft/bedrock
      curl https://raw.githubusercontent.com/Microsoft/bedrock/master/gitops/azure-devops/build.sh > build.sh
      chmod +x ./build.sh

      # install hub if using GitHub repos
      sudo add-apt-repository ppa:cpick/hub
      sudo apt-get update
      sudo apt-get install hub

      # source build.sh
      . build.sh --source-only

      # execute build.sh functions
      verify_access_token
      init
      helm init
      get_os
      get_fab_version
      download_fab
      git_connect

      # extract branch name and build # from the full subcomponent
      branch_name=$(Build.SourceBranchName)
      build_id=$(Build.BuildId)
      repo_name=$(Build.Repository.Name)
      repo="${repo_name#*/}"

      # run 'fab remove' to remove ring
      echo "FAB REMOVE"
      fab remove $repo-$branch_name
      # need to specify the subcomponent as an environment variable (e.g. "hello-rings-featurea")

      echo "GIT ADD"
      git add -A

      pr_branch_name="PR-ring-removal-$branch_name-$build_id"
      git checkout -b $pr_branch_name

      # set git identity
      git config user.email "admin@azuredevops.com"
      git config user.name "Automated Account"

      echo "GIT COMMIT"
      git commit -m "Deleting ring $branch_name"

      echo "GIT PUSH"
      git_push

      # create pull request using hub
      export GITHUB_TOKEN=$ACCESS_TOKEN_SECRET
      hub version
      hub pull-request -m "Removing RING $branch_name"
    displayName: 'Remove Subcomponent'
```

The following pipeline variables are required for the Azure DevOps Build:

```
ACCESS_TOKEN_SECRET: the personal access token to access the source and HLD repository
REPO: the service HLD repository
SRC_REPO: the application source repository
```
