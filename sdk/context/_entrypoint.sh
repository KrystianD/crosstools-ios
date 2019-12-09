#!/bin/bash
set -ex

cat > /tmp/patterns <<EOF
./Xcode*/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/*
./Xcode*/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/*
EOF

mkdir -p /tmp/sdk && cd /tmp/sdk

xar --extract --file /xcode.xip Content --to-stdout | \
    pbzx | \
    xz --threads=0 --decompress | \
    cpio --extract --pattern-file=/tmp/patterns --no-absolute-filenames --make-directories

OUT_FILE=/sdk.tar

pushd /tmp/sdk/Xcode*.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/
tar -cf ${OUT_FILE} *
popd

pushd /tmp/sdk/Xcode*.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/
tar -rf ${OUT_FILE} *
popd
