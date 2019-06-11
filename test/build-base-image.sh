#!/bin/bash
#---------- see https://github.com/joelong01/BashWizard ----------------
# bashWizard version 1.0.0
# this will make the error text stand out in red - if you are looking at these errors/warnings in the log file
# you can use cat <logFile> to see the text in color.
function echoError() {
    RED=$(tput setaf 1)
    NORMAL=$(tput sgr0)
    echo "${RED}${1}${NORMAL}"
}
function echoWarning() {
    YELLOW=$(tput setaf 3)
    NORMAL=$(tput sgr0)
    echo "${YELLOW}${1}${NORMAL}"
}
function echoInfo() {
    GREEN=$(tput setaf 2)
    NORMAL=$(tput sgr0)
    echo "${GREEN}${1}${NORMAL}"
}
function echoIfVerbose() {
    if [[ "$verbose" == true ]]; then
        echo "${@}"
    fi
}
# make sure this version of *nix supports the right getopt
! getopt --test 2>/dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echoError "'getopt --test' failed in this environment. please install getopt."
    read -r -p "install getopt using brew? [y,n]" response
    if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
        brew install gnu-getopt
        #shellcheck disable=SC2016
        echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile
        echoWarning "you'll need to restart the shell instance to load the new path"
    fi
   exit 1
fi

function usage() {
    
    echo "Builds the docker test harness base image. This image comes pre-installed with Azure CLI, GO, Dep, GCC, git, unzip, wget, terraform, kubectl, helm. This base image also pre-installs the golang vendor packages."
    echo ""
    echo "Usage: $0  -g|--go_version -t|--tf_version " 1>&2
    echo ""
    echo " -g | --go_version     Optional     GOLang version"
    echo " -t | --tf_version     Optional     Terraform version"
    echo ""
    exit 1
}
function echoInput() {
    echo "build-base-image.sh:"
    echo -n "    go_version.... "
    echoInfo "$go_version"
    echo -n "    tf_version.... "
    echoInfo "$tf_version"
}

function parseInput() {
    local OPTIONS=g:t:
    local LONGOPTS=go_version:,tf_version:

    # -use ! and PIPESTATUS to get exit code with errexit set
    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out "--options")
    # -pass arguments only via -- "$@" to separate them correctly
    ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        # e.g. return value is 1
        # then getopt has complained about wrong arguments to stdout
        usage
        exit 2
    fi
    # read getopt's output this way to handle the quoting right:
    eval set -- "$PARSED"
    while true; do
        case "$1" in
        -g | --go_version)
            go_version=$2
            shift 2
            ;;
        -t | --tf_version)
            tf_version=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echoError "Invalid option $1 $2"
            exit 3
            ;;
        esac
    done
}

function build_image(){
    echoInfo "INFO: Building base image"
    echoInput
    declare docker_tag="g${go_version}t${tf_version}"
    echoInfo "$docker_img - $docker_file"
    docker build -f $docker_file \
        -t $docker_img:$docker_tag . \
        --build-arg gover=$go_version \
        --build-arg tfver=$tf_version
}

declare go_version="1.11"
declare tf_version="0.11.13"

parseInput "$@"
declare docker_img="msftcse/bedrock-test-base"
declare docker_file="test/docker/base-images/Dockerfile"

build_image