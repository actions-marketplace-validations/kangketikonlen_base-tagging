#!/bin/bash
set -eu

# Setting up github function
git_setup() {
    git config --global user.email "actions@github.com"
    git config --global user.name "Base tagging gitHub action"
}

# Push tags function
push_tags() {
    git tag -a "v${1}" -m "Auto generated tags ${1}" "${GITHUB_SHA}" -f
    git push --tags -f
    exit 0
}

echo "Start process..."
git_setup
git fetch origin --tags --quiet

# Retrieve message and branch repo
MESSAGE=$(git log -1 HEAD --pretty=format:%s)
BRANCH=$(git symbolic-ref --short HEAD)
echo "Using commit message: ${MESSAGE} on branch ${BRANCH}"

# Skip creating tags if commit message contain #TRY keyword
flag=$(echo $MESSAGE | awk '{print match($0,"#TRY")}')
if [ $flag -gt 0 ]; then
    echo "Using tag #try, skip creating tags"
    exit 0
fi

# Retrieving last tags
# Use default tags if commit message contain #FIRST keyword
flag=$(echo $MESSAGE | awk '{print match($0,"#FIRST")}')
if [ $flag -gt 0 ]; then
    LAST_TAG="1.0"
    echo "Using default tag: ${LAST_TAG}"
    push_tags $LAST_TAG
else
    LAST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
    echo "Last tag: ${LAST_TAG}"
fi

# Remove "v" from last tag.
LAST_TAG=$(echo $LAST_TAG | sed -e 's/^v//')
VERSI=$(echo $LAST_TAG | grep -o '[^-]*$')

# Get major number
MAJOR=$(echo $VERSI | cut -d. -f1)
# Get patch number
PATCH=$(echo $VERSI | cut -d. -f2)

# Check branch to define wich number will be increased.
if [ $BRANCH == "main" ]; then
    NEXT_MAJOR=$(($MAJOR + 1))
    LATEST_TAG="${NEXT_MAJOR}.0"
    echo "There is major update. Latest tags: ${LATEST_TAG}"
    push_tags $LATEST_TAG
else
    NEXT_PATCH=$(($PATCH + 1))
    LATEST_TAG="${MAJOR}.${NEXT_PATCH}"
    echo "There is patch update. Latest tags: ${LATEST_TAG}"
    push_tags $LATEST_TAG
fi
