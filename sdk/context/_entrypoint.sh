#!/bin/bash
set -ex

mkdir -p /tmp/sdk && cd /tmp/sdk

xar --extract --file /xcode.xip Content
pbzx -n Content | \
  cpio --extract --no-absolute-filenames --make-directories

OUT_FILE=/sdk.tar

pushd /tmp/sdk/Xcode*.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/
tar -cf ${OUT_FILE} iPhoneOS.sdk
popd

pushd /tmp/sdk/Xcode*.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/
tar -rf ${OUT_FILE} iPhoneSimulator.sdk
popd
