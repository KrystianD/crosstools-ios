#!/usr/bin/env bash
cd $(dirname "$0")

if [[ ! -e ../sdk/sdk.tar ]]; then
    echo "sdk.tar doesn't exist in sdk/ directory. Please create SDK first"
    exit 1
fi

tar -cf - -C context/ . -C ../../sdk/ ./sdk.tar | docker build -t crosstools-ios:libtapi1300-xar5fa4-omp56d94-cctools1009-ldid4bf8-sdk11_3-llvm3b5b -
