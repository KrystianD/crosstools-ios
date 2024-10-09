crosstools-ios
========

Dockerized iOS build environment based on [cctools-port](https://github.com/tpoechtrager/cctools-port) 

Supports **iPhone (arm64)** and **iPhone Simulator (x86_64, arm64)** targets.

Tested on Xcode 15.3

#### Building

1. Create SDK - see [sdk/README.md](sdk/README.md)

2. Build image

```bash
./crosstools-ios/build_image.sh
```
