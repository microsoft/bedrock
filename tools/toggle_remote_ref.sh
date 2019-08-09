#!/bin/bash
# This script helps toggle the remote version reference within the current
# checkout repository.  This will help facilitate the process of doing 
# pull requests where the remote referenced modules changed.
#
# It is assumed that remote source URLs are of the form:
#
# github.com/<entity>/<repository>?ref=<current version>//...
#
# Note, this script will make changes to the current files checked out.
set -x
while getopts :c:v: option
do
 case "${option}" in
 c) CURRENT_VERSION=${OPTARG};;
 v) NEW_VERSION=${OPTARG};;
 *) echo "Please refer to usage guide on GitHub" >&2
    exit 1 ;;
 esac
done

entity_name="microsoft"
project_name="bedrock"

if [ -z "$NEW_VERSION" ]; then
    echo "version to update remote references to is required"
    exit 1
fi

if [ -c "$CURRENT_VERSION" ]; then
    echo "version to update remote references to is required"
    exit 1
fi

NEW_VERSION=`echo $NEW_VERSION | sed 's/\./\\\./'`
CURRENT_VERSION=`echo $CURRENT_VERSION | sed 's/\./\\\./'`

read -p "This script will modify files in this checked out repository.  Are you sure you want to continue? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # go to base Bedrock directory (relative to this script location which is 
    # <top level>/tools.
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    cd $SCRIPT_DIR/..

    # determine files that need updating
    FILE_SEARCH=`grep -r "source[ ]\{0,\}=[ ]\{0,\}\"github.com\/$entity_name\/$project_name" * | awk '{print $1}' | grep ".tf" | sort -u | sed "s/://"`
    echo $FILE_SEARCH

    # update files 
    for f in $FILE_SEARCH; do
        sed -i -r "s/source[ ]{0,}=[ ]{0,}\"github.com\/$entity_name\/$project_name\?ref=$CURRENT_VERSION\/\/(.*)\"/source = \"github.com\/$entity_name\/$project_name\?ref=$NEW_VERSION\/\/\1/g" $f
    done

    echo "remote references updated"
fi
