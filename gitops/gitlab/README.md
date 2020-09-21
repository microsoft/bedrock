# GitOps CI/CD with Gitlab

This repository contains pipelines and scripts that enable GitOps through [Gitlab CI](https://docs.gitlab.com/ee/ci/). The patterns here are an adaptation of the GitOps for Azure DevOps pattern, which you can read more about [here](../azure-devops/../PipelineThinking.md).

## Use Cases

### HLD manifest change

When a PR is made against the HLD repository, this pipeline will automate the posting of a comment that will show the file diffs that will occur in the downstream manifest repository.

When a PR is merged into the HLD repository, this pipeline will automatically apply the changes to the downstream manifest repository. 

> **Note**: Manifests are generated using [Fabrikate](https://github.com/microsoft/fabrikate)

### Application deployment after application CI

This pipeline makes it easy to automate the staging of new image builds to a configurable environment. An example of this is to stage a deployment to the `dev` environment after PR merges in the application repository. This requires coordination from the application CI pipeline and relies on [Pipeline Triggers](https://docs.gitlab.com/ee/ci/triggers/).

If added to the **application pipeline**, the following stanza will automate the creation of a PR that stages the latest build to a `dev` environment:

```yaml
trigger-hld-mr:
  stage: .post
  image: curlimages/curl:7.72.0
  script:
    - curl --fail -X POST
        -F "token=$HLD_TRIGGER_TOKEN"                                       # Trigger Token Variable
        -F "ref=main"                                                       # Default branch in HLD repository
        -F "variables[ENVIRONMENT]=dev"                                     # Environment to create PR for
        -F "variables[DOCKER_TAG]=$CI_COMMIT_SHORT_SHA"                     # Docker Tag
        "$CI_API_V4_URL/projects/$HLD_TRIGGER_PROJECT_ID/trigger/pipeline"  # API to invoke Ci in HLD repository
  rules:
    - if: $CI_MERGE_REQUEST_IID                                             # Don't run on merge requests
      when: never
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'                         # Only run on default branch builds
```

## Overview

The table below outlines the files required by this pipeline:

| File | Description |
| ---  | ---         |
| `.gitlab-ci.yml` | A [Gitlab CI](https://docs.gitlab.com/ee/ci/yaml/) file that contains the structure and order of the CICD pipeline |
| `.ci/build.sh` | Logic to automate application deployment to a stage after application CI. Invoked upon PR creation from a API trigger |
| `.ci/diff.sh` | Logic to automate the posting of a comment with a diff of the downstream manifest repository repo. Invoked upon PR creation |
| `.ci/release.sh` | Logic to release changes to manifest repository. Invoked upon PR merge |
| `.ci/shared.sh` | Logic used by all stages, such as manifest generation |

## Usage

You will need to configure some project-specific values in order to use this pipeline. The steps are outlined below:

```bash
########################
# Helm Configuration

# Root of application helm chart configuration. Ex: "config"
HELM_CHART_RELATIVE_ROOT="..."

# YAML path to image tag configuaation element. Ex: "subcomponents.foo.config.image.tag"
IAMGE_TAG_CONFIG_PATH="..."

sed -i '' "s/{{HELM_CHART_RELATIVE_ROOT}}/$HELM_CHART_RELATIVE_ROOT/g" .ci/build.sh
sed -i '' "s/{{IAMGE_TAG_CONFIG_PATH}}/$IAMGE_TAG_CONFIG_PATH/g" .ci/build.sh



########################
# Gitlab Configuration

# For public gitlab, this can be "gitlab.com"
GITLAB_HOST="..."

# This is the git clone URL of the HLD/Manifest repository.
# Note: You will need to escape any '/' characters with a '\'. #x: https://gitlab.com/foo-group\/foo\/bar.git
CLUSTER_MANIFESTS_REPO="..."

sed -i '' "s/{{GITLAB_HOST}}/$GITLAB_HOST/g" .gitlab-ci.yml
sed -i '' "s/{{CLUSTER_MANIFESTS_REPO}}/$CLUSTER_MANIFESTS_REPO/g" .gitlab-ci.yml



########################
# Git configuration

GIT_USER_EMAIL="..."
GIT_USER_NAME="..."

sed -i '' "s/{{GIT_USER_EMAIL}}/$GIT_USER_EMAIL/g" .gitlab-ci.yml
sed -i '' "s/{{GIT_USER_NAME}}/$GIT_USER_NAME/g" .gitlab-ci.yml
```
