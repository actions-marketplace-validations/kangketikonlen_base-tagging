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
git pull
git fetch origin --tags --quiet

last_tag=`git describe --tags $(git rev-list --tags --max-count=1)`
echo "Last tag: ${last_tag}";

if [ -z "${last_tag}" ];then
    last_tag="v0.1.0";
    echo "Default Last tag: ${last_tag}";
fi

MESSAGE=$(git log -1 HEAD --pretty=format:%s)

if [[ "$MESSAGE" == *\[major\]* ]]; then
	echo "increase first digit"
elif [[ "$MESSAGE" == *\[minor\]* ]]; then
	echo "increase middle digit"
else
	echo "increase last digit"
fi
