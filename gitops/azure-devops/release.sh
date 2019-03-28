# Source build.sh
. build.sh --source-only

# Initialization
verify_access_token
init
helm init
get_os

# Fabrikate
get_fab_version
download_fab

# Clone HLD repo
git clone $MANIFEST_REPO --branch=master
cd fabrikate-go-server

# Fabrikate (Part 2)
install_fab

echo "FAB SET"
fab set --subcomponent go-server image.tag=$(Build.BuildNumber)

echo "GIT STATUS"
git status

echo "GIT ADD"
git add config/common.yaml

# Set git identity
git config user.email "admin@azuredevops.com"
git config user.name "Automated Account"

echo "GIT COMMIT"
git commit -m "Updating image tag to $(Build.BuildNumber)"

echo "GIT PUSH"
git_push
