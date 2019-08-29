# NAME: init.sh
# Notable exported functions: 
# 1. template_build_targets: compares the source and upstream branch to determines which terraform template directories were modified.
# 2. check_required_env_variables: verifies that required environment variables are defined. 
# USAGE: template_build_targets $BUILD_UPSTREAMBRANCH $BUILD_SOURCEBRANCHNAME
#        check_required_env_variables

#!/usr/bin/env bash
set -euo pipefail

declare -A TEST_RUN_MAP=()
declare BUILD_TEMPLATE_DIRS="build"
declare BUILD_TEST_RUN_IMAGE="cluster-test"
declare readonly TEMPLATE_DIR="/test"
declare readonly GIT_DIFF_EXTENSION_WHITE_LIST="*.go|*.tf|*.sh|Dockerfile*|*.tfvars"

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
function dotenv() {
    set -a
    [ -f .env ] && . .env
    set +a
}

function rebuild_test_image() {
    declare base_image=$1
    echoInfo "INFO: Using base image tag $base_image"
    docker build --rm -f "test/Dockerfile" \
        --build-arg build_directory="$BUILD_TEMPLATE_DIRS" \
        -t ${BUILD_TEST_RUN_IMAGE}:${BUILD_BUILDID} \
        --build-arg base_image=$base_image .
}

function remove_build_directory() {
    if [ -d "$BUILD_TEMPLATE_DIRS" ]; then rm -Rf $BUILD_TEMPLATE_DIRS; fi
}

function check_required_env_variables() {
    echoInfo "INFO: Checking required environment variables"
    for var in BUILD_BUILDID ARM_SUBSCRIPTION_ID ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID ARM_ACCESS_KEY TF_VAR_remote_state_container TF_VAR_remote_state_account ; do
        if [[ ! -v ${var} ]] ; then
            echoError "ERROR: $var is not set in the environment"
            return 0
        fi
    done
    echoInfo "INFO: passed environment variable check"
}

function default_to_all_template_paths() {
    echoInfo "INFO: Terraform module file(s) changed. Running all tests"
	declare -a ALL_TEMPLATE_DIRS=(`find $TEMPLATE_DIR/* -maxdepth 0 -type d`)
    shopt -s nullglob
    for folder in "${ALL_TEMPLATE_DIRS[@]}"
    do
        IFS='/' read -a folder_array <<< "${folder}"
        TEST_RUN_MAP[${folder_array[2]}]=$folder
    done
}

function add_template_if_not_exists() {
    declare readonly template_name=$1
    declare readonly template_directory="$TEMPLATE_DIR/$template_name"
    if [[ -z ${TEST_RUN_MAP[$template_name]+unset} && -d "$template_directory" ]]; then
        TEST_RUN_MAP[$template_name]="$template_directory"
    fi;
}

function load_build_directory() {
    template_dirs=$( IFS=$' '; echo "${TEST_RUN_MAP[*]}" )
    echoInfo "INFO: Running local build for templates: $template_dirs"
    mkdir $BUILD_TEMPLATE_DIRS && cp -r $template_dirs *.go $BUILD_TEMPLATE_DIRS
}

# Builds the test harness off the template changes from the git log
function build_test_harness() {
    GIT_DIFF_UPSTREAMBRANCH=$1
    GIT_DIFF_SOURCEBRANCH=$2
    BASE_IMAGE=$3
    echoInfo "INFO: verified that environment is fully defined"
    template_build_targets $GIT_DIFF_UPSTREAMBRANCH $GIT_DIFF_SOURCEBRANCH
    echoInfo "INFO: Building test harness image"
    rebuild_test_image $BASE_IMAGE
    if [ -d "$BUILD_TEMPLATE_DIRS" ]; then rm -Rf $BUILD_TEMPLATE_DIRS; fi
}

# Builds the test harness based on the template name provided from the user
function build_test_harness_from_template() {
    BASE_IMAGE=$1
    TEMPLATE_NAME=$2
    add_template_if_not_exists $TEMPLATE_NAME
    echoInfo "INFO: moving terraform files for template $TEMPLATE_NAME to ${BUILD_TEMPLATE_DIRS}/"
    load_build_directory
    echoInfo "INFO: Building test harness image"
    rebuild_test_image $BASE_IMAGE
    if [ -d "$BUILD_TEMPLATE_DIRS" ]; then rm -Rf $BUILD_TEMPLATE_DIRS; fi
}

function template_build_targets() {
    GIT_DIFF_UPSTREAMBRANCH=$1
    GIT_DIFF_SOURCEBRANCH=$2
    [[ -z $GIT_DIFF_UPSTREAMBRANCH ]] && echoError "ERROR: GIT_DIFF_UPSTREAMBRANCH wasn't provided" && return 1

    [[ -z $GIT_DIFF_SOURCEBRANCH ]] && echoError "ERROR: GIT_DIFF_SOURCEBRANCH wasn't provided" && return 1

    echoInfo "INFO: Running git diff from branch ${GIT_DIFF_SOURCEBRANCH}"
    files=(`git diff ${GIT_DIFF_UPSTREAMBRANCH} ${GIT_DIFF_SOURCEBRANCH} --name-only|grep -E ${GIT_DIFF_EXTENSION_WHITE_LIST}||true`)
    for file in "${files[@]}"
    do
        IFS='/' read -a folder_array <<< "${file}"
        if [ ${#folder_array[@]} -lt 3 ]; then
            continue
        fi

        if [ ${folder_array[0]}=='test-harness' ]; then 
            default_to_all_template_paths
            break 
        fi
        
        case ${folder_array[1]} in
            'modules')
                default_to_all_template_paths
                break
                ;;
            'templates') declare readonly template_name=${folder_array[2]}
                add_template_if_not_exists $template_name
                ;;
        esac
    done

    if [ ${#TEST_RUN_MAP[@]} -eq 0 ]; then
        echoWarning "INFO: No templates to process. Exiting build step"
        exit 0
    fi

    load_build_directory
}
