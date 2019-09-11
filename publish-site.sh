#!/usr/bin/env bash

set -o errexit # exit immediately if a command exits with a non-zero status.

RED='\033[0;31m'
GREEN='\033[0;32m'
INVERTED='\033[7m'
NC='\033[0m' # No Color

ROOT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function checkIfAllChangesAreCommited {
    if [[ $(git status -s) ]]
    then
        echo -e "${RED}The working directory is dirty. Please commit any pending changes.${NC}"
        exit 1;
    fi
} 

function prunePublicDirectory {
    echo -e "${INVERTED}Deleting old publication${NC}"
    rm -rf public
    mkdir public
    git worktree prune
    rm -rf .git/worktrees/public/
    echo -e "${GREEN}OK\n${NC}"

    echo -e "${INVERTED}Checking out gh-pages branch into public${NC}"
    git worktree add -B gh-pages public origin/gh-pages
    echo -e "${GREEN}OK\n${NC}"

    echo -e "${INVERTED}Removing existing files${NC}"
    rm -rf public/*
    echo -e "${GREEN}OK\n${NC}"
}

function regenerateSite {
    echo -e "${INVERTED}Generating site${NC}"
    cd ${ROOT_PATH}/site
    hugo -D
    echo -e "${GREEN}OK\n${NC}"
    cd ${ROOT_PATH}
}

function copyTalksDirs {
    cp -r 2017/ public/2017
    cp -r 2018/ public/2018
    cp -r 2019/ public/2019
}

function commitPublicDir {
    echo -e "${INVERTED}Updating gh-pages branch${NC}"
    cd  ${ROOT_PATH}/public && git add --all && git commit -m "auto-commit (publish-site.sh): Update gh-pages" && git push origin gh-pages
    echo -e "${GREEN}OK\n${NC}"
}

checkIfAllChangesAreCommited

prunePublicDirectory

regenerateSite
copyTalksDirs
commitPublicDir