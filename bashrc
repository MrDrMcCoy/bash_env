#!/usr/bin/env bash

cd "${HOME}/bash_env"
source main
cd - >/dev/null
export PATH="${PATH}:/usr/lib/jvm/java-19-graalvm/bin"
