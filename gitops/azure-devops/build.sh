#!/usr/bin/env bash

function verify_access_token() {
    echo "VERIFYING PERSONAL ACCESS TOKEN"
    if [[ -z "$ACCESS_TOKEN_SECRET" ]]; then
        echo "Please set env var ACCESS_TOKEN_SECRET for git host: $GIT_HOST"
        exit 1
    fi
}
function verify_repo() {
    echo "CHECKING HLD/MANIFEST REPO URL"
    # shellcheck disable=SC2153
    if [[ -z "$REPO" ]]; then
        echo "HLD/MANIFEST REPO URL not specified in variable $REPO"
        exit 1
    fi
}

function init() {
    cp -r ./* "$HOME/"
    cd "$HOME"
}

# Initialize Helm
function helm_init() {
    echo "RUN HELM INIT"
    helm init --client-only
}

# Obtain version for Fabrikate
# If the version number is not provided, then download the latest Helm2 compatible version
# The Major version number can be provided as the first argument, 
function get_fab_version() {
    # shellcheck disable=SC2153
    if [ -z "$VERSION" ]
    then
        # By default, the script will use the Helm 2 compatible, non-prerelease, non-draft release Fabrikate.
        MAJOR=${1:-0} 
        VERSIONS=$(curl -s "https://api.github.com/repos/microsoft/fabrikate/git/matching-refs/tags/$MAJOR" | grep "/refs/tags/$MAJOR" | while read -r line ; do
            VERSION=${line##*/}
            VERSION=${VERSION%\",}
            echo "$VERSION"
        done | sort -V)
        VERSION_TO_DOWNLOAD=${VERSIONS##*$'\n'}
        echo $VERSION_TO_DOWNLOAD
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
    fab_wget=$(wget -q -SO- "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip" 2>&1 | grep -E -i "302")
    if [[ $fab_wget == *"302 Found"* ]]; then
       echo "Fabrikate $VERSION_TO_DOWNLOAD downloaded successfully."
    else
        echo "There was an error when downloading Fabrikate. Please check version number and try again."
    fi
    filename=$(uuidgen)
    wget -q -O "$filename.zip" "https://github.com/Microsoft/fabrikate/releases/download/$VERSION_TO_DOWNLOAD/fab-v$VERSION_TO_DOWNLOAD-$os-amd64.zip"
    unzip "$filename.zip" -d fab

    export PATH=$PATH:$HOME/fab
}

# Install the HLD repo if it's not running as part of the HLD build pipeline
function install_hld() {
    echo "DOWNLOADING HLD REPO"
    echo "git clone $HLD_PATH"
    git clone "$HLD_PATH"
    # Extract repo name from url
    repo=${HLD_PATH##*/}
    repo_name=${repo%%.*}
    echo "Setting HLD path to $repo_name"
    cd "$repo_name"

    # if branch name is specified, switch to that HLD branch 
    if [ -z "$HLD_BRANCH" ]; then
        git checkout $HLD_BRANCH
    fi

    echo "HLD DOWNLOADED SUCCESSFULLY"
}

# Install Fabrikate
function install_fab() {
    # Run this command to make script exit on any failure
    echo "FAB INSTALL"
    set -e

    if [ -z "$HLD_PATH" ]; then
        echo "HLD path not specified, going to run fab install in current dir"
    else
        echo "HLD repo specified: $HLD_PATH"
        install_hld
    fi
    fab install
    echo "FAB INSTALL COMPLETED"
}


# Run fab generate
function fab_generate() {
    # For backwards compatibility, support pipelines that have not set this variable
    echo "CHECKING FABRIKATE ENVIRONMENTS"
    if [ -z "$FAB_ENVS" ]; then
        echo "FAB_ENVS is not set"
        echo "FAB GENERATE prod"
        fab generate prod
    else
        echo "FAB_ENVS is set to $FAB_ENVS"
        IFS=',' read -ra ENV <<< "$FAB_ENVS"
        for i in "${ENV[@]}"; do
            echo "FAB GENERATE $i"
            # In this case, we do want to split the string by unquoting $i so that the fab generate command
            # recognizes multiple environments as separate strings.
            # shellcheck disable=SC2086
            fab generate $i
        done
    fi

    echo "FAB GENERATE COMPLETED"
    set +e

    # If generated folder is empty, quit
    # In the case that all components are removed from the source hld,
    # generated folder should still not be empty
    if find "generated" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
        export manifest_files_location=$(pwd)
        echo "Manifest files have been generated in 'pwd'."
    else
        echo "Manifest files could not be generated in 'pwd', quitting..."
        exit 1
    fi
}

function manifest_diff_into_pr() {
    echo $1
    echo $2 
    HLD_BRANCH=$2
    
    download_fab
    install_fab
    fab_generate
    git_connect

    rm -rf */

    if [ -z "$FAB_ENVS" ]; then
        cp -a $manifest_files_location/. .
    else
        IFS=',' read -ra ENV <<< "$FAB_ENVS"
        for i in "${ENV[@]}"
        do
        cp -R ../generated/$i ./
        done
    fi

    if [[ $(git status --porcelain) ]]; then
        echo "The following diff will be applied to cluster-manifests upon merge:" > diff.txt
        git diff | tee -a diff.txt
        MESSAGE=$(sed 's/^.\{1,\}$/"&"/' diff.txt)
        echo "az repos pr update --id $1 --description $(echo ${MESSAGE:0:4000})"

        # description only allows 4000 characters at max
        az repos pr update --id $1 --description $(echo ${MESSAGE:0:4000})
    else
        echo "Manifest generation files will not be modified at all."
        az repos pr update --id $1 --description "Manifest generation files will not be modified at all."
    fi

}

# Support backward compat for a bit
function get_spk_version() {
    # shellcheck disable=SC2153  
    echo -e "WARNING: ACTION REQUIRED\n**** 'get_spk_version' is DEPRECATED and will be removed. ****\n**** Please use 'get_bedrock_version' ****"
    echo "Ignoring VERSION env var and using v0.6.3"
    # Last version of spk. Please use get_bedrock_version instead. 
    SPK_VERSION_TO_DOWNLOAD="v0.6.3"
}

# Obtain version for Bedrock CLI
# If the version number is not provided, then download the latest
function get_bedrock_version() {
    # shellcheck disable=SC2153
    if [ -z "$VERSION" ]
    then
        # By default, the script will use the most recent non-prerelease, non-draft release Bedrock CLI
        CLI_VERSION_TO_DOWNLOAD=$(curl -s "https://api.github.com/repos/microsoft/bedrock-cli/releases/latest" | grep "tag_name" | sed -E 's/.*"([^"]+)".*/\1/')
    else
        echo "Bedrock CLI Version: $VERSION"
        CLI_VERSION_TO_DOWNLOAD=$VERSION
    fi
}

# Obtain OS to download the appropriate version of Bedrock CLI
function get_os_bedrock() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        eval "$1='linux'"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        eval "$1='macos'"
    elif [[ "$OSTYPE" == "msys" ]]; then
        eval "$1='win.exe'"
    else
        eval "$1='linux'"
    fi
}

# Support backward compat for a bit
function download_spk() {
    echo -e "WARNING: ACTION REQUIRED\n**** 'download_spk' is DEPRECATED and will be removed. ****\n**** Please use 'download_bedrock' ****"
    echo "DOWNLOADING deprecated SPK"
    echo "Deprecated SPK Version: $SPK_VERSION_TO_DOWNLOAD"
    os=''
    get_os_bedrock os
    spk_wget=$(wget -q -SO- "https://github.com/microsoft/bedrock-cli/releases/download/$SPK_VERSION_TO_DOWNLOAD/spk-$os" 2>&1 | grep -E -i "302")
    if [[ $spk_wget == *"302 Found"* ]]; then
    echo "SPK $SPK_VERSION_TO_DOWNLOAD downloaded successfully."
    else
        echo "There was an error when downloading SPK. Please check version number and try again."
    fi
    wget -q "https://github.com/microsoft/bedrock-cli/releases/download/$SPK_VERSION_TO_DOWNLOAD/spk-$os"
    mkdir spk
    mv spk-$os spk/spk
    chmod +x spk/spk 

    export PATH=$PATH:$HOME/spk
}

# Download Bedrock CLI
function download_bedrock() {
    echo "DOWNLOADING BEDROCK CLI"
    echo "Latest CLI Version: $CLI_VERSION_TO_DOWNLOAD"
    os=''
    get_os_bedrock os
    bedrock_cli_wget=$(wget -SO- "https://github.com/microsoft/bedrock-cli/releases/download/$CLI_VERSION_TO_DOWNLOAD/bedrock-$os" 2>&1 | grep -E -i "302")
    if [[ $bedrock_cli_wget == *"302 Found"* ]]; then
    echo "Bedrock CLI $CLI_VERSION_TO_DOWNLOAD downloaded successfully."
    else
        echo "There was an error when downloading Bedrock CLI. Please check version number and try again."
    fi
    wget "https://github.com/microsoft/bedrock-cli/releases/download/$CLI_VERSION_TO_DOWNLOAD/bedrock-$os"
    mkdir bedrock
    mv bedrock-$os bedrock/bedrock
    chmod +x bedrock/bedrock 

    export PATH=$PATH:$HOME/bedrock
}

# Authenticate with Git
function git_connect() {
    cd "$HOME"
    # Remove http(s):// protocol from URL so we can insert PA token
    repo_url=$REPO
    repo_url="${repo_url#http://}"
    repo_url="${repo_url#https://}"

    echo "GIT CLONE: https://automated:<ACCESS_TOKEN_SECRET>@$repo_url"
    git clone "https://automated:$ACCESS_TOKEN_SECRET@$repo_url"
    retVal=$? && [ $retVal -ne 0 ] && exit $retVal

    # Extract repo name from url
    repo_url=$REPO
    repo=${repo_url##*/}
    repo_name=${repo%.*}

    cd "$repo_name"
    echo "GIT PULL ORIGIN MASTER"
    git pull origin master
}

# Git commit
function git_commit() {
    echo "GIT CHECKOUT $BRANCH_NAME"
    if ! git checkout "$BRANCH_NAME" ; then
        git checkout -b "$BRANCH_NAME"
    fi

    echo "GIT STATUS"
    git status
    echo "GIT REMOVE"
    rm -rf ./*/
    git rm -rf ./*/
    echo "COPY YAML FILES FROM $manifest_files_location/generated/ TO REPO DIRECTORY..."
    cp -r "$manifest_files_location/generated/"* .
    echo "GIT ADD"
    git add -A

    #Set git identity
    git config user.email "admin@azuredevops.com"
    git config user.name "Automated Account"

    # Following variables have to be set for TeamCity
    export GIT_AUTHOR_NAME="Automated Account"
    export GIT_COMMITTER_NAME="Automated Account"
    export EMAIL="admin@azuredevops.com"

    if [[ $(git status --porcelain) ]]; then
        echo "GIT COMMIT"
        git commit -m "Updated k8s manifest files post commit: $COMMIT_MESSAGE"
        retVal=$? && [ $retVal -ne 0 ] && exit $retVal
    else
        echo "NOTHING TO COMMIT"
    fi

    echo "GIT PULL origin $BRANCH_NAME"
    git pull origin "$BRANCH_NAME"
}

# Checks for changes and only commits if there are changes staged. Optionally can be configured to fail if called to commit and no changes are staged.
# First arg - commit message
# Second arg - "should error if there is nothing to commit" flag. Set to 0 if this behavior should be skipped and it will not error when there are no changes.
# Third arg - variable to check if changes were commited or not. Will be set to 1 if changes were made, 0 if not.
function git_commit_if_changes() {

    echo "GIT STATUS"
    git status

    echo "GIT ADD"
    git add -A

    commitSuccess=0
    if [[ $(git status --porcelain) ]] || [ -z "$2" ]; then
        echo "GIT COMMIT"
        git commit -m "$1"
        retVal=$?
        if [[ "$retVal" != "0" ]]; then
            echo "ERROR COMMITING CHANGES -- MAYBE: NO CHANGES STAGED"
            exit $retVal
        fi
        commitSuccess=1
    else
        echo "NOTHING TO COMMIT"
    fi
    echo "commitSuccess=$commitSuccess"
    printf -v $3 "$commitSuccess"
}

# Perform a Git push
function git_push() {
    # Remove http(s):// protocol from URL so we can insert PA token
    repo_url=$REPO
    repo_url="${repo_url#http://}"
    repo_url="${repo_url#https://}"

    echo "GIT PUSH: https://<ACCESS_TOKEN_SECRET>@$repo_url"
    git push "https://$ACCESS_TOKEN_SECRET@$repo_url"
    retVal=$? && [ $retVal -ne 0 ] && exit $retVal
    echo "GIT STATUS"
    git status
}

function unit_test() {
    echo "Sourcing build.sh ..."
}

function verify_pull_request() {
    echo "Starting verification"
    init
    helm_init
    get_fab_version
    download_fab
    install_fab
    fab_generate
}

# Run functions
function verify_pull_request_and_merge() {
    verify_repo
    verify_access_token
    verify_pull_request
    echo "Verification complete, push to yaml repo"
    git_connect
    git_commit
    git_push
}

echo "argument is ${1}"
if [[ "$VERIFY_ONLY" == "1" ]]; then
    verify_pull_request
elif [ "${1}" == "--source-only" ]; then
    unit_test
else
    verify_pull_request_and_merge
fi
