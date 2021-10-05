#!/usr/bin/env bash
cd $(dirname "$0")

if [[ ! -e ../sdk/sdk.tar ]]; then
    echo "sdk.tar doesn't exist in sdk/ directory. Please create SDK first"
    exit 1
fi

tar -cf - -C context/ . -C ../../sdk/ ./sdk.tar | docker build -t crosstools-ios -
