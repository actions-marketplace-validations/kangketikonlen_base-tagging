#!/bin/sh
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
    git config --global user.email "actions@github.com"
    git config --global user.name "Base tagging gitHub action"
}

echo "###################"
echo "Tagging Parameters"
echo "###################"
echo "GITHUB_ACTOR: ${GITHUB_ACTOR}"
echo "GITHUB_TOKEN: ${GITHUB_TOKEN}"
echo "HOME: ${HOME}"
echo "###################"
echo ""
echo "Start process..."

echo "1) Setting up git machine..."
git_setup

echo "2) Updating repository tags..."
git fetch origin --tags --quiet

last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`

if [ -z "${last_tag}" ];then
    if [ "${INPUT_FLAG_BRANCH}" != false ];then
        last_tag="${INPUT_PREV_TAG}${branch}.1.0";
    else
        last_tag="${INPUT_PREV_TAG}0.1.0";
    fi
    echo "Default Last tag: ${last_tag}";
fi