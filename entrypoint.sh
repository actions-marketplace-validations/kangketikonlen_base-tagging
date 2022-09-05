#!/bin/bash
set -eu

# Set up .netrc file with GitHub credentials
git_setup() {
    git config --global user.email "actions@github.com"
    git config --global user.name "Base tagging gitHub action"
}

echo "Start process..."

echo "1) Setting up git machine..."
git_setup

echo "2) Updating repository tags..."
git fetch origin --tags --quiet

MESSAGE=$(git log -1 HEAD --pretty=format:%s | tr '[:lower:]' '[:upper:]')
echo $MESSAGE

flag=$(echo $MESSAGE | awk '{print match($0,"FIRST")}')
if [ $flag -gt 0 ]; then
    last_tag="0.1.0"
else
    last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
fi

echo "Last tag: ${last_tag}"

VERSION=$(echo $last_tag | grep -o '[^-]*$')

major=$(echo $VERSION | cut -d. -f1)
minor=$(echo $VERSION | cut -d. -f2)
patch=$(echo $VERSION | cut -d. -f3)

flag=$(echo $MESSAGE | awk '{print match($0,"#MAJOR")}')
if [ $flag -gt 0 ]; then
    echo "Major ${major}+1"
fi

flag=$(echo $MESSAGE | awk '{print match($0,"#MINOR")}')
if [ $flag -gt 0 ]; then
    echo "Minor ${minor}+1"
fi
