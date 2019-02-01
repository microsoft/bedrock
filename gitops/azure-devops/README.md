# GitOps with Azure DevOps
Components of a GitOps workflow
<img src="PAT.svg?sanitize=true">

Here's an example setup for azure-pipelines.yml. Two variables need to be created as part of the azure pipelines build

- `accesstoken` this one should contain the personal access token and made secret
- `aks_manifest_repo` this one should contain the url to destination repo in the format: `username/repo_name` 


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
