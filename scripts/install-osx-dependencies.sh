#!/usr/bin/env sh -x
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    brew update
    brew install llvm ccache install redis
fi
