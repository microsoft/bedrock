#!/bin/bash

set -euo pipefail

dir=$(dirname $0)
. "$dir/shared.sh" --source-only

echo "CI_PIPELINE_SOURCE=$CI_PIPELINE_SOURCE"

COMMIT_MSG=$(git log -1 --pretty=%B)

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
  echo "GIT COMMIT & PUSH"
  git add .
  git commit -m "[CI] $COMMIT_MSG"
  git push
else
  echo "NOTHING TO COMMIT"
fi
