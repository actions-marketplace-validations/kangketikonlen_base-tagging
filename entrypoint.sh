#!/bin/bash
set -eu

git_setup() {
    git config --global user.email "actions@github.com"
    git config --global user.name "Base tagging gitHub action"
}

push_tags() {
    git tag -a $1 -m "Auto generated tags ${1}" "${GITHUB_SHA}" -f
    git push --tags -f
    exit 0
}

echo "Start process..."
git_setup
git fetch origin --tags --quiet

MESSAGE=$(git log -1 HEAD --pretty=format:%s | tr '[:lower:]' '[:upper:]')
echo "Using commit message: ${MESSAGE}"

flag=$(echo $MESSAGE | awk '{print match($0,"#TRY")}')
if [ $flag -gt 0 ]; then
    echo "Using tag #try, skip creating tags"
    exit 0
fi

flag=$(echo $MESSAGE | awk '{print match($0,"#FIRST")}')
if [ $flag -gt 0 ]; then
    last_tag="v0.1.0"
    echo "Default tag: ${last_tag}"
    push_tags $last_tag
else
    last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
    echo "Last tag: ${last_tag}"
fi

VERSI=$(echo $last_tag | grep -o '[^-]*$')
MAJOR=$(echo $VERSI | cut -d. -f1)
MINOR=$(echo $VERSI | cut -d. -f2)
PATCH=$(echo $VERSI | cut -d. -f3)

flag=$(echo $MESSAGE | awk '{print match($0,"#BASE")}')
if [ $flag -gt 0 ]; then
    NEXT_MAJOR=$(($MAJOR + 1))
    NEXT_TAGS="v${NEXT_MAJOR}.${MINOR}.${PATCH}"
    echo "There is major update. Latest tags: ${NEXT_TAGS}"
    push_tags $NEXT_TAGS
else
    echo "No major update."
fi

flag=$(echo $MESSAGE | awk '{print match($0,"#FITUR")}')
if [ $flag -gt 0 ]; then
    NEXT_MINOR=$(($MINOR + 1))
    NEXT_TAGS="v${MAJOR}.${NEXT_MINOR}.${PATCH}"
    echo "There is minor update. Latest tags: ${NEXT_TAGS}"
    push_tags $NEXT_TAGS
else
    echo "No minor update."
fi

flag=$(echo $MESSAGE | awk '{print match($0,"#PERBAIKAN")}')
if [ $flag -gt 0 ]; then
    NEXT_PATCH=$(($PATCH + 1))
    NEXT_TAGS="v${MAJOR}.${MINOR}.${NEXT_PATCH}"
    echo "There is patch update. Latest tags: ${NEXT_TAGS}"
    push_tags $NEXT_TAGS
else
    echo "No patch update."
fi
