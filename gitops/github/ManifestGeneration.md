# Guide: Manifest Generation Pipeline

This section describes how to configure Azure Devops to be your CI/CD orchestrator for your GitOps Workflow. You will create a manifest generation pipeline using Fabrikate.

## Prerequisites

1. _Permissions_: The ability to create Projects in your Github Organization.
2. _High Level Deployment Description_: Either your own [Fabrikate](https://github.com/Microsoft/fabrikate) high level definition for your deployment or a sample one of ours.  We provide a [sample HLD repo](https://github.com/andrebriggs/fabrikate-sample-app) that builds upon the [cloud-native](https://github.com/timfpark/fabrikate-cloud-native) Fabrikate definition.

## Setup

### 1. Create Repositories and Personal Access Tokens

Create both high level definition (HLD) and resource manifest repos and the personal access tokens that you'll use for the two ends of this CI/CD pipeline.  We have instructions for how to do that in two flavors:
* [Azure DevOps](../docs/ADORepos.md)
* [GitHub](../docs/GitHubRepos.md)

#### Add Github actions workflow YAML
If you are using your own high level description, add the following [`workflow.yml`](./workflow.yml) file to the .github/workflows directory to defines the build steps for your Github actions workflow.

```
on:
  push:
    branches:
      - main
      - master
  
  pull_request:
    branches:
      - main
      - master

jobs:
  FabrikateToManifest:

    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Download Bedrock orchestration script
        run: |
          curl $BEDROCK_BUILD_SCRIPT > build.sh
          chmod +x ./build.sh
        shell: bash
        env:
          BEDROCK_BUILD_SCRIPT: https://raw.githubusercontent.com/Microsoft/bedrock/master/gitops/azure-devops/build.sh

  
      - uses: azure/setup-helm@v1
        with:
          version: '2.17.0' # default is latest stable
        id: install

      - name: Validate fabrikate definitions
        run: |
          chmod +x ./build.sh
          ./build.sh
        shell: bash
        env:
          MAJOR: 1
          VERIFY_ONLY: 1

      - name: Get branch name
        shell: bash
        run: echo "##[set-output name=branch_name;]$(echo ${GITHUB_REF#refs/heads/})"
        id: get_branch_name

      - name: Transform fabrikate definitions and publish to YAML manifests to repo
        run: |
          ./build.sh
        shell: bash
        env:
          MAJOR: 1
          ACCESS_TOKEN_SECRET: ${{ secrets.ACCESS_TOKEN }}
          COMMIT_MESSAGE: ${{ github.event.head_commit.message }}
          REPO: ${{ secrets.MANIFEST_REPO }}
          BRANCH_NAME: ${{ steps.get_branch_name.outputs.branch_name }}
```

### 2. Create workflow

We use an [Github workflow](https://github.com/features/actions) to build your high level description into resource manifests:

1. On a pull request (pre push to master) it executes a simple validation on proposed changes to infrastructure definition in the HLD repo.
1. On a merge to master branch (post push to master) it executes a script to transform the high level definition to YAML using [Fabrikate](https://github.com/Microsoft/fabrikate) and pushes the generated results into the resource manifest repo.

__Note__: If you would like to trigger a build from a pipeline not linked to the high level definition repo, you can define a variable `HLD_PATH` and pass it into the script with other variables as shown above in `workflow.yml`. You need to set this to a git URL, such as `git://github.com/Microsoft/fabrikate-production-cluster-demo.git`.

#### Create Build for your Definition Repo

With Github actions you do not need to setup the workflow. Commit and push the yml to the workflows directory and its set.

#### Configure Build

1. Click the "Secrets" tab.

5. Add two variables that are used by the `build.sh` script referenced in `workflow.yml`:
    1. __Name__: `ACCESS_TOKEN` (_mandatory_) __Value__: Personal Access Token ([Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops) or [GitHub](https://www.help.github.com/articles/creating-a-personal-access-token-for-the-command-line)) for your repo type.
    2.  __Name__: `MANIFEST_REPO` (_mandatory_) __Value__: The full URL to your manifest repo (i.e. https://github.com/andrebriggs/acme-company-yaml.git)
    3. __Name__: `FAB_ENVS` (_optional_) __Value__: Comma-separated list of environments for which you have specified a config in your high level definition repo. If this variable is not created in the pipeline, the script will generate manifest files for a generic `prod` environment. For example, you may set this variable to `prod-east, prod-west` depending on your configuration.

7. You should now see the build run and complete successfully.

### 3. Configure Flux

Once you have your Github workflow is working, you will need to retrieve the SSH public key you used to [set up your cluster](../../cluster/common/flux/README.md).

1. Copy the SSH key to your clipboard.

2. In Github actions, under Settings > Deploy kets, click on `Add deploy key` and add the Flux deploy key.
  ![ssh](images/ssh-key.png)

3. On your cluster find the name of your pod by executing `kubectl get pods -n flux`
    ```
    $ kubectl get pods -n flux
    NAME                              READY   STATUS    RESTARTS   AGE
    flux-7d459f5f9-c2wtd              1/1     Running   0          24h
    flux-memcached-59947476d9-49xs6   1/1     Running   0          24h
    ```

4. Monitor the logs of your running Flux instance using the command `kubectl logs POD_NAME -n flux` to ensure that the initial manifest YAML files are being applied to your cluster.
```
$ kubectl logs flux-7d459f5f9-c2wtd -n flux
ts=2019-02-14T19:37:55.332948174Z caller=main.go:156 version=1.10.1
ts=2019-02-14T19:37:55.408911845Z caller=main.go:247 component=cluster identity=/etc/fluxd/ssh/identity
ts=2019-02-14T19:37:55.414659575Z caller=main.go:417 url=git@github.com:andrebriggs/aks-feb-manifest.git user="Weave Flux" email=support@weave.works sync-tag=flux-sync notes-ref=flux set-author=false
...
...
```
Now, when a change is commited to the resource manifest repo, Flux should acknowledge the commit and make changes to the state of your cluster as necessary. You can monitor Flux by viewing the logs by running `kubectl logs POD_NAME -n flux -f` in stream mode.

### 4. Make a Pull Request

1. Create a new branch in your HLD repo and make a commit to the high level definition.

1. For example, let's say we wanted to make a change that dropped the `cloud-native` stack and instead added directly a Elasticsearch / Fluentd / Kibana logging stack and Prometheus / Grafana metrics monitoring stack to your definition.  We would make a commit that made this change:
  ![ADO Build](images/definition-change.png)

1. Then, create a pull request to merge your changes into master/main branch.

1. Once these checks have passed and the PR has been approved by your team process, you can merge it into master.

### 5. Monitor Repository Changes
1. Once merged, you can monitor the progress of the HLD transformation in the Actions tab.

1. When the commit is merged into master/main, your workflow will build the resource manifests for this definition and check them into the resource manifest repo.

1. Once the build is successful, navigate to your manifest repository. You should see a very recent commit to the main branch.

### 6. Monitor Cluster Changes

1. Next, [Flux](https://github.com/weaveworks/flux/blob/master/site/get-started.md#confirm-the-change-landed) will automatically apply the build resource manifest changes to your cluster.  You can watch this with the following `kubectl` command:

```
$ kubectl logs POD_NAME -n flux -f
```

2. You can also use [Kubediff](https://github.com/weaveworks/kubediff) to make sure the applied resource manifests in your cluster match your resource manifest repo by cloning your resource manifest repo and then running:

```
$ kubediff ./cloned-resource-manifest-repo
```

3. Finally, you should watch your normal operational metrics to make sure the change was successful.