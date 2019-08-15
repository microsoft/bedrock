#!/bin/bash
# This script automates the process of creating a branch that can be the 
# base for a release of Bedrock.  It updates any remote URL references in
# the repository to point to the version being created.
#
# The process is as follows:
#
# - create temporary directory
# - clone the repository
# - switch to branch if one specified
# - create new branch for version
# - update remote sources to new version number
# - push branch update 
#
# It is assumed that remote source URLs are of the form:
#
# github.com/<entity>/<repository>?ref=<current version>//...
#
REPOSITORY="https://github.com/microsoft/bedrock.git"
CURRENT_VERSION="master"
SAVE_TMP_DIR=false

while getopts :r:c:v:so: option
do
 case "${option}" in
 r) REPOSITORY=${OPTARG};;
 c) CURRENT_VERSION=${OPTARG};;
 v) NEW_VERSION=${OPTARG};;
 s) SAVE_TMP_DIR=true;;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

if [ -z "$NEW_VERSION" ]; then
    echo "version to create branch for required"
    exit 1
fi

# create temporary workspace
tmp_dir=$(mktemp -d -t rel-XXXXXXXXXX)
function finish {
    if $SAVE_TMP_DIR; then
        echo "tmp directory kept -- $tmp_dir"
    else
        echo "removing tmp directory"
        rm -rf $tmp_dir
    fi
}
trap finish EXIT

# clone repository
cd $tmp_dir
git clone $REPOSITORY
if [ $? -ne 0 ]; then
    echo "unable to checkout $REPOSITORY"
    exit 1
fi

# change to the repository directory
project_name=`echo $REPOSITORY | awk -F"/" '{print $NF}' | sed 's/\.git//'`
cd $project_name
entity_name=`echo $REPOSITORY | awk -F"/" '{print $(NF-1)}'`

# if the current revision is different than "master" attempt to retrieve that branch
if [ "$CURRENT_VERSION" != "master" ]; then
    # does the revision exist?
    git branch --all | grep $CURRENT_VERSION
    if [ $? -ne "0" ]; then 
        echo "branch $CURRENT_VERSION does not exist"
        exit 1
    fi

    # verify there aren't multiple matching branches
    branch_count=`git branch --all | grep $CURRENT_VERSION | wc -l`
    if [ $branch_count -ne 1 ]; then 
        echo "$CURRENT_VERSION does not refer to an actual branch.  multiple matches found."
        exit 1
    fi

    git checkout $CURRENT_VERSION
    if [ $? -ne 0 ]; then
        echo "unable to checkout $CURRENT_VERSION"
        exit 1
    fi
fi

# determine files that need updating
FILE_SEARCH=`grep -r "source[ ]\{0,\}=[ ]\{0,\}\"github.com\/$entity_name\/$project_name" * | awk '{print $1}' | grep ".tf" | sort -u | sed "s/://"`
echo $FILE_SEARCH

# update files 
for f in $FILE_SEARCH; do
    sed -i -r "s/source[ ]{0,}=[ ]{0,}\"github.com\/$entity_name\/$project_name\?ref=$CURRENT_VERSION\/\/(.*)\"/source = \"github.com\/$entity_name\/$project_name\?ref=$NEW_VERSION\/\/\1\"/g" $f
done

# create new branch and commit
git checkout -b $NEW_VERSION
git add `git status | grep modified | awk '{print $2}'`
git commit -m "create branch for $NEW_VERSION"
git push --set-upstream origin $NEW_VERSION

echo "branch for $NEW_VERSION created"
