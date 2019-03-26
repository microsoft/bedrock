#!/bin/sh

# variables for deployment
GITOPS_SSH_URL="{insert the ssh url to the gitops github repo here}"
GITOPS_SSH_BRANCH="master"
GITOPS_SSH_KEY="{insert the path to the private ssh key file here}"
FLUX_REPO_URL="https://github.com/weaveworks/flux.git"
REPO_ROOT_DIR="repo-root"

# install flux into cluster
./../../common/flux/deploy_flux.sh -g $GITOPS_SSH_URL -b $GITOPS_SSH_BRANCH -k $GITOPS_SSH_KEY -f $FLUX_REPO_URL -d $REPO_ROOT_DIR