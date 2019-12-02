#!/usr/bin/env sh -x

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
    (redis-server&);
fi
