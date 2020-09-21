#!/bin/bash

set -euo pipefail

dir=$(dirname $0)
. "$dir/shared.sh" --source-only

if [[ -z "$GITLAB_TOKEN" ]]; then
  echo "The variable 'GITLAB_TOKEN' is required to push the diff to the merge request."
  exit 1
fi

echo "GENERATE MANIFESTS FROM HLD"
generate_manifests

# checkout cluster-manifests repo
echo "CLONE MANIFESTS REPO"
git clone "$CLUSTER_MANIFESTS_REPO" cluster-manifests
cd cluster-manifests

echo "REPLACE MANIFESTS"
rm -rf ./*
for i in "${ENVIRONMENTS[@]}"
do
  cp -R ../generated/$i ./
done

if [[ $(git status --porcelain) ]]; then
  echo "The following diff will be applied to cluster-manifests upon merge:" > diff.txt
  echo \`\`\`diff >> diff.txt
  git diff | tee -a diff.txt
  echo \`\`\` >> diff.txt
  MESSAGE=$(cat diff.txt)
  curl -X POST -g \
    -H "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
    --data-urlencode "body=${MESSAGE}" \
    "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/merge_requests/${CI_MERGE_REQUEST_IID}/discussions"
else
  echo "NOTHING TO COMMIT"
fi
