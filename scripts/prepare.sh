#!/usr/bin/env sh -x

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    export PATH="/usr/local/opt/ccache/libexec:$PATH"
fi

if [[ "$TRAVIS_OS_NAME" != "osx" && "$CXX" = "g++" ]]; then
    export CXX="g++-4.8" CC="gcc-4.8"
fi
