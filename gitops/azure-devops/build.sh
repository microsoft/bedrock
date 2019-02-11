function init() {
    cp -r * $HOME/
    cd $HOME

    if [[ "$GIT_TYPE" == "github" ]]; then
        git_dest_repo="https://github.com/$AKS_MANIFEST_REPO"
        git_type=$GIT_TYPE
    elif [[ "$GIT_TYPE" == "azure" ]]; then
        git_dest_repo="https://dev.azure.com/$AKS_MANIFEST_REPO" # For repos that reside in Azure Devops, the AKS_MANIFEST_REPO should be formatted like "user_account/project_name/_git/repo_name"
        git_type="dev.azure"   
    fi
}

# Initialize Helm
function helm_init() {
    echo "RUN HELM INIT"
    helm init
    echo "HELM ADD INCUBATOR"
    if [ -z "$HELM_CHART_REPO" ] || [ -z "$HELM_CHART_REPO_URL" ];
    then
        echo "Using DEFAULT helm repo..."
        helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
    else
        echo "Using DEFINED helm repo..."
        helm repo add $HELM_CHART_REPO $HELM_CHART_REPO_URL
    fi
}

# Obtain version for Fabrikate
# If the version number is not provided, then download the latest
function get_fab_version() {
    if [ -z "$VERSION" ]
    then
        VERSIONS=$(curl -s https://api.github.com/repos/Microsoft/fabrikate/tags)
        LATEST_RELEASE=$(echo $VERSIONS | grep "name" | head -1)
        VERSION_TO_DOWNLOAD=`echo "$LATEST_RELEASE" | cut -d'"' -f 4`
    else
        echo "Fabrikate Version: $VERSION"
        VERSION_TO_DOWNLOAD=$VERSION
    fi
}

# Obtain OS to download the appropriate version of Fabrikate
function get_os() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        eval "$1='linux'"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        eval "$1='darwin'"
    elif [[ "$OSTYPE" == "msys" ]]; then
        eval "$1='windows'"
    else
        eval "$1='linux'"
    fi
}

# Download Fabrikate
function download_fab() {
    echo "DOWNLOADING FABRIKATE"
    echo "Latest Fabrikate Version: $VERSION_TO_DOWNLOAD"
    os=''
    get_os os
    fab_wget=$(wget -SO- "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip" 2>&1 | egrep -i "302")
    if [[ $fab_wget == *"302 Found"* ]]; then
       echo "Fabrikate $VERSION_TO_DOWNLOAD downloaded successfully."
    else
        echo "There was an error when downloading Fabrikate. Please check version number and try again."
    fi
    wget "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip"
    unzip fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip -d fab
}

# Install Fabrikate
function install_fab() {
    export PATH=$PATH:$HOME/fab
    fab install
    echo "FAB INSTALL COMPLETED"
}

# Run fab generate
function fab_generate() {
    fab generate prod --no-validation
    echo "FAB GENERATE COMPLETED"

    # If generated folder is empty, quit
    # In the case that all components are removed from the source hld, 
    # generated folder should still not be empty
    if find "$HOME/generated" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
        echo "Manifest files have been generated."
    else
        echo "Manifest files could not be generated, quitting..."
        exit 1
    fi  
}

# Authenticate with Git
function git_connect() {
    cd $HOME
    echo "GIT CLONE"
    git clone $git_dest_repo
    repo_url=$git_dest_repo
    repo=${repo_url##*/}

    # Extract repo name from url
    repo_name=${repo%.*}
    cd $repo_name
}

# Git commit
function git_commit() {
    echo "GIT CHECKOUT"
    git checkout master
    echo "GIT STATUS"
    git status
    echo "COPY YAML FILES TO REPO DIRECTORY..."
    rm -rf prod/
    cp -r $HOME/generated/* .
    echo "GIT ADD"
    git add *

    #Set git identity 
    git config user.email "admin@azuredevops.com"
    git config user.name "Automated Account"

    echo "GIT COMMIT"
    git commit -m "Updated k8s manifest files post commit: $COMMIT_MESSAGE"
    echo "GIT STATUS" 
    git status
    echo "GIT PULL" 
    git pull
}

# Perform a Git push
function git_push() {
    echo "GIT PUSH"
    git push https://$ACCESS_TOKEN@$git_type.com/$AKS_MANIFEST_REPO
    echo "GIT STATUS"
    git status
}

function unit_test() {
    echo "Sourcing for unit test..."
}

function verify() {
    echo "Starting verification"
    init
    helm_init
    get_fab_version
    download_fab
    install_fab
    fab_generate
}

# Run functions
function verify_and_push() {
    verify
    echo "Verification complete, push to yaml repo"
    git_connect
    git_commit
    git_push
}

echo "argument is ${1}"
if [ "${1}" == "--verify-only" ]; then
    verify
elif [ "${1}" == "--source-only" ]; then
    unit_test
else
    verify_and_push
fi
