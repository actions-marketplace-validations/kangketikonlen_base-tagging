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

echo "###################"
echo "Tagging Parameters"
echo "###################"
echo "DEFAULT Flag: ${INPUT_DEFAULT_FLAG}"
echo "MAJOR Flag: ${INPUT_MAJOR_FLAG}"
echo "MINOR Flag: ${INPUT_MINOR_FLAG}"
echo "PATCH Flag: ${INPUT_PATCH_FLAG}"
echo "###################"

echo "Start process..."
git_setup
git fetch origin --tags --quiet

MESSAGE=$(git log -1 HEAD --pretty=format:%s | tr '[:lower:]' '[:upper:]')
echo $MESSAGE

flag=$(echo $MESSAGE | awk '{print match($0,"${INPUT_DEFAULT_FLAG}")}')
if [ $flag -gt 0 ]; then
    last_tag="0.1.0"
    echo "Default tag: ${last_tag}"
    push_tags $last_tag
else
    last_tag=$(git describe --tags $(git rev-list --tags --max-count=1))
    echo "Last tag: ${last_tag}"
fi

echo "3) Creating next repository tags..."
VERSI=$(echo $last_tag | grep -o '[^-]*$')

MAJOR=$(echo $VERSI | cut -d. -f1)
MINOR=$(echo $VERSI | cut -d. -f2)
PATCH=$(echo $VERSI | cut -d. -f3)

flag=$(echo $MESSAGE | awk '{print match($0,"$INPUT_MAJOR_FLAG")}')
if [ $flag -gt 0 ]; then
    NEXT_MAJOR=$(($MAJOR + 1))
    NEXT_TAGS="${NEXT_MAJOR}.${MINOR}.${PATCH}"
    echo "Perubahan di versi major ${NEXT_TAGS}"
    push_tags $NEXT_TAGS
fi

flag=$(echo $MESSAGE | awk '{print match($0,"$INPUT_MINOR_FLAG")}')
if [ $flag -gt 0 ]; then
    NEXT_MINOR=$(($MINOR + 1))
    NEXT_TAGS="${MAJOR}.${NEXT_MINOR}.${PATCH}"
    echo "Perubahan di versi minor ${NEXT_TAGS}"
    push_tags $NEXT_TAGS
fi

flag=$(echo $MESSAGE | awk '{print match($0,"$INPUT_PATCH_FLAG")}')
if [ $flag -gt 0 ]; then
    NEXT_PATCH=$(($PATCH + 1))
    NEXT_TAGS="${MAJOR}.${MINOR}.${NEXT_PATCH}"
    echo "Perubahan di versi patch ${NEXT_TAGS}"
    push_tags $NEXT_TAGS
fi
