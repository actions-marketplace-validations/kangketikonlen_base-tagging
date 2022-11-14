# BASE TAGGING
[![Build Status](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fkangketikonlen%2Fbase-tagging%2Fbadge%3Fref%3Dstable&style=flat)](https://actions-badge.atrox.dev/kangketikonlen/base-tagging/goto?ref=stable)
\
If you feel creating tag manually is pain in the ass, well, I feel you... and you come to the right place. This action script will manage your tags and package version. You only need to create a personal token, set it to your repository secret and how many tags you want to keep and put it on your repository.

# How to use
Below, is a sample script that I use in this repository. You can copy and paste this script and create tag.yml or whatever.yml file under **<repo-name>/.github/workflows/tag.yml**
```yml
on:
  push:
    branches: 
      - "stable"

env:
  IMAGE_NAME: ${{ github.event.repository.name }}

name: 🔖 Create Auto Tag
jobs:
  build:
    name: 🔖 Bump tag
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Create tagc
      uses: kangketikonlen/base-tagging@stable
      env:
        REPO_NAME: ${{ github.event.repository.name }}
        REPO_TYPE: ${{ github.event.repository.owner.type }}
        REPO_OWNER: ${{ github.event.repository.owner.name }}
        PERSONAL_TOKEN: ${{ secrets.PERSONAL_TOKEN }}
        PRESERVE_VERSION: 1
```
You need to change some variable above to suit your environment. Don't forget to create a personal access token, see the documentation [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).
