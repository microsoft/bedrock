# GitOps with Azure DevOps
Components of a GitOps workflow:
<img src="PAT.svg?sanitize=true">
The following variables *need* to be created as part of the azure pipelines build:

- `ACCESS_TOKEN`: The personal access token (encrypted)
- `GIT_HOST`: The Git host that is used (for now, only GitHub and Azure DevOps are supported)

The `build.sh` supports repositories held in GitHub or in Azure DevOps. Although, this needs to be explicitly specified as environment variables in the pipeline build. If using GitHub repos, the variable `GIT_HOST` should be specified as `github`, and for Azure DevOps repos, the variable should be `azure`.

- `AKS_MANIFEST_REPO`: The url to destination repo. Depending on the git host, the format could be the following:
  - `username/repo_name` (GitHub)
  - `username/project_name/_git/repo_name` (Azure DevOps)

Here's an example setup for azure-pipelines.yml

```
trigger:
- master

pool:
  vmImage: 'Ubuntu-16.04'

steps:
- checkout: self
  persistCredentials: true
  clean: true

- bash: |
    chmod +x ./build.sh && ./build.sh --verify-only
  condition: eq(variables['Build.Reason'], 'PullRequest')

- task: ShellScript@2
  inputs:
    scriptPath: build.sh
  condition: ne(variables['Build.Reason'], 'PullRequest')
  env:
    ACCESS_TOKEN: $(accesstoken)
    COMMIT_MESSAGE: $(Build.SourceVersionMessage)
    AKS_MANIFEST_REPO: $(aks_manifest_repo)
```
## A note on Flux

This GitOps workflow relies heavily on [Flux](https://github.com/weaveworks/flux), which is a DevOps tool that ensures the state of the Kubernetes cluster aligns with the config in the AKS Manifest repo. Flux has been tested to support both GitHub and Azure DevOps repos However, configuration for both may differ.

For Github repos, instructions for configuring Flux are noted [here](https://github.com/weaveworks/flux/blob/master/site/get-started.md#get-started-with-flux).

For Azure DevOps repos, instructions for configuring Flux follow this [documentation](https://github.com/weaveworks/flux/blob/master/site/standalone-setup.md#using-a-private-git-host). In summary, the following steps need to take place:

1. Like GitHub, you need to run `fluxctl identity` once Flux is running on a cluster.
2. In Azure DevOps, under your `User Profile > Security > SSH public keys, click on `Add` and add the Flux deploy key.
3. From there, follow the steps in getting Flux to work with [private git hosts](https://github.com/weaveworks/flux/blob/master/site/standalone-setup.md#using-a-private-git-host). The git host to known host file is `ssh.dev.azure.com`

