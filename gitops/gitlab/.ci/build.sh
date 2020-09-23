#!/bin/bash

set -euo pipefail

dir=$(dirname $0)
. "$dir/shared.sh" --source-only

echo "CI_COMMIT_BRANCH=$CI_COMMIT_BRANCH"
echo "CI_PIPELINE_SOURCE=$CI_PIPELINE_SOURCE"
echo "ENVIRONMENT=$ENVIRONMENT"
echo "DOCKER_TAG=$DOCKER_TAG"

echo "RECONFIGURE REMOTE FOR SSH"
url_host=$(echo "${CI_REPOSITORY_URL}" | sed -e 's|https\?://gitlab-ci-token:.*@|ssh://git@|g')
git remote set-url --push origin "${url_host}"

echo "GIT CHECKOUT MERGE REQUEST BRANCH"
git fetch
(git checkout $BRANCH_NAME && git pull) || git checkout -b $BRANCH_NAME

echo "UPDATE IMAGE TAG -> $DOCKER_TAG"
yq w -i --style=double {{HELM_CHART_RELATIVE_ROOT}}/$ENVIRONMENT.yaml {{IAMGE_TAG_CONFIG_PATH}} "$DOCKER_TAG"

if [[ $(git status --porcelain) ]]; then
  echo "GIT COMMIT & PUSH W/ MERGE"
  git add config/$ENVIRONMENT.yaml
  git commit -m "[AUTOMATED] Updating $ENVIRONMENT configuration with image tag $DOCKER_TAG"

  # NOTE: push options require GitLab runner version 11.10
  # DOCS: https://docs.gitlab.com/ee/user/project/push_options.html
  git push -u \
    -o merge_request.create \
    -o merge_request.remove_source_branch \
    -o merge_request.target="master" \
    -o merge_request.label="automated" \
    origin $BRANCH_NAME
else
  echo "NOTHING TO COMMIT"
fi
