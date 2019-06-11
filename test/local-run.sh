#!/bin/bash
#---------- see https://github.com/joelong01/BashWizard ----------------
# bashWizard version 1.0.0
# this will make the error text stand out in red - if you are looking at these errors/warnings in the log file
# you can use cat <logFile> to see the text in color.

. ./test/init.sh --source-only

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
    
    echo "Builds and runs the test harness container. This container runs all build target tasks on the host machine. These targets include mage clean, format, unit and integration tests. This base image also pre-installs the golang vendor. "
    echo ""
    echo "Usage: $0  -b|--docker_base_image_name -a|--template_name_override " 1>&2
    echo ""
    echo " -b | --docker_base_image_name                       Optional     "
    echo " -t | --template_name_override                       Optional     "
    echo ""
    exit 1
}
function echoInput() {
    echo "local-run.sh:"
    echo -n "    docker_base_image_name...................... "
    echoInfo "$docker_base_image_name"
    echo -n "    template_name_override.... "
    echoInfo "$template_name_override"

}

function parseInput() {

    local OPTIONS=b:t:
    local LONGOPTS=docker_base_image_name:,template_name_override:

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
        -b | --docker_base_image_name)
            docker_base_image_name=$2
            shift 2
            ;;
        -t | --template_name_override)
            template_name_override=$2
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

# Bind environment from .env
dotenv

# input variables
declare docker_base_image_tag="g${GO_VERSION}t${TF_VERSION}"
declare docker_base_image_name="msftcse/bedrock-test-base:$docker_base_image_tag"
declare template_name_override=""

# Parse user input arguments
parseInput "$@"

readonly BUILD_SOURCEBRANCHNAME=`git branch | sed -n '/\* /s///p'`
readonly BUILD_UPSTREAMBRANCH="master"

function run_test_harness() {
    echoInfo "INFO: loading environment"
    check_required_env_variables
    echoInput
    echoInfo "INFO: verified that environment is fully defined"
    remove_build_directory
    case "$template_name_override" in
        "")        build_test_harness $BUILD_UPSTREAMBRANCH \
                       $BUILD_SOURCEBRANCHNAME \
                       $docker_base_image_name ;;
        *)         build_test_harness_from_template $docker_base_image_name \
                       $template_name_override ;;
    esac

    run_test_image
}

function run_test_image() {
    echoInfo "INFO: Running test harness container"
    docker run -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
            -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
            -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
            -e ARM_TENANT_ID=$ARM_TENANT_ID \
            -e DATACENTER_LOCATION=$DATACENTER_LOCATION \
            -e TF_VAR_remote_state_account=$TF_VAR_remote_state_account \
            -e TF_VAR_remote_state_container=$TF_VAR_remote_state_container \
            -e ARM_ACCESS_KEY=$ARM_ACCESS_KEY \
            --rm $BUILD_TEST_RUN_IMAGE:$BUILD_BUILDID

    echoInfo "INFO: Completed test run"
}

run_test_harness