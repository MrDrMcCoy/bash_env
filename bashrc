#!/usr/bin/env bash

cd "${HOME}/bash_env"
git pull origin master --recurse-submodules --progress
source main
cd -
