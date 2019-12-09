#!/usr/bin/env bash
cd $(dirname "$0")

if [[ ! -e ../sdk/iPhoneOS.sdk.tar ]]; then
    echo "iPhoneOS.sdk.tar doesn't exist in sdk/ directory. Please create SDK first"
    exit 1
fi

tar -cf - -C context/ . -C ../../sdk/ ./iPhoneOS.sdk.tar | docker build -t crosstools-ios -
