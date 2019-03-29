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
git_connect

# Fabrikate (Part 2)
install_fab

echo "FAB SET"
fab set --subcomponent $SUBCOMPONENT $PATH=$PATH_VALUE

echo "GIT STATUS"
git status

echo "GIT ADD"
#git add config/common.yaml
git add .

# Set git identity
git config user.email "admin@azuredevops.com"
git config user.name "Automated Account"

echo "GIT COMMIT"
git commit -m $COMMIT_MESSAGE

echo "GIT PUSH"
git_push
