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
    echo "Default tag: ${last_tag}"
    exit 1
else
    last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
    echo "Last tag: ${last_tag}"
fi

VERSI=$(echo $last_tag | grep -o '[^-]*$')

MAJOR=$(echo $VERSI | cut -d. -f1)
MINOR=$(echo $VERSI | cut -d. -f2)
PATCH=$(echo $VERSI | cut -d. -f3)

flag=$(echo $MESSAGE | awk '{print match($0,"PERUBAHAN")}')
if [ $flag -gt 0 ]; then
    NEXT_MAJOR=$MAJOR+1
    echo "Perubahan di versi major ${NEXT_MAJOR}"
fi

# flag=$(echo $MESSAGE | awk '{print match($0,"FITUR")}')
# if [ $flag -gt 0 ]; then
#     NEXT_MINOR=$MINOR+1
#     echo "Perubahan di versi minor ${NEXT_MINOR}"
# fi

# flag=$(echo $MESSAGE | awk '{print match($0,"PERBAIKAN")}')
# if [ $flag -gt 0 ]; then
#     NEXT_PATCH=$PATCH+1
#     echo "Perubahan di versi patch ${NEXT_PATCH}"
# fi
