FROM ubuntu:22.04 as base

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq \
        autoconf automake libtool libssl-dev libz-dev libblocksruntime-dev

ENV MAKEFLAGS=-j$(nproc)

#################
##### cmake #####
#################
FROM base as builder-cmake

ARG CMAKE_VERSION=3.18.0

RUN mkdir cmake && cd cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar -xf cmake-${CMAKE_VERSION}.tar.gz && \
    cd cmake-${CMAKE_VERSION} && \
    ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX=/opt/cmake && \
    make && \
    make install && \
    rm -rf /root/cmake

###################
##### libtapi #####
###################
FROM base as builder-libtapi

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=$PATH:/opt/cmake/bin

RUN git clone https://github.com/tpoechtrager/apple-libtapi.git --depth 1 --branch 1300.6.5

RUN cd apple-libtapi && \
    git clean -xfd && \
    INSTALLPREFIX=/usr/arm-apple-darwin11 \
        ./build.sh && ./install.sh

RUN cd apple-libtapi && \
    git clean -xfd && \
    INSTALLPREFIX=/usr/x86_64-ios-simulator \
        ./build.sh && ./install.sh

RUN cd apple-libtapi && \
    git clean -xfd && \
    INSTALLPREFIX=/usr/arm64-ios-simulator \
        ./build.sh && ./install.sh

###############
##### xar #####
###############
FROM base as builder-xar

RUN git clone https://github.com/tpoechtrager/xar && \
    cd xar && \
    git checkout 5fa4675419cfec60ac19a9c7f7c2d0e7c831a497

RUN cd xar/xar; \
    git clean -xfd; \
    ./autogen.sh \
        --prefix=/usr \
        CFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu/"; \
    ./configure --prefix=/usr/arm-apple-darwin11 && \
    make && \
    make install

RUN cd xar/xar; \
    git clean -xfd; \
    ./autogen.sh \
        --prefix=/usr \
        CFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu/"; \
    ./configure --prefix=/usr/x86_64-ios-simulator && \
    make && \
    make install

RUN cd xar/xar; \
    git clean -xfd; \
    ./autogen.sh \
        --prefix=/usr \
        CFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu/"; \
    ./configure --prefix=/usr/arm64-ios-simulator && \
    make && \
    make install

FROM base as builder-libdispatch

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=$PATH:/opt/cmake/bin

RUN git clone https://github.com/tpoechtrager/apple-libdispatch && \
    cd apple-libdispatch && \
    git checkout fdf3fc85a9557635668c78801d79f10161d83f12

RUN cd apple-libdispatch && \
    rm -rf build && mkdir build && cd build && \
    cmake \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_INSTALL_PREFIX=/usr/arm-apple-darwin11 \
        --with-blocks-runtime /usr/include \
        .. && \
    make && \
    make install

RUN cd apple-libdispatch && \
    rm -rf build && mkdir build && cd build && \
    cmake \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_INSTALL_PREFIX=/usr/x86_64-ios-simulator \
        --with-blocks-runtime /usr/include \
        .. && \
    make && \
    make install

RUN cd apple-libdispatch && \
    rm -rf build && mkdir build && cd build && \
    cmake \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_INSTALL_PREFIX=/usr/arm64-ios-simulator \
        --with-blocks-runtime /usr/include \
        .. && \
    make && \
    make install

###################
##### cctools #####
###################
FROM base as builder-cctools

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential \
        clang libxml2-dev libssl-dev unzip jq autoconf automake libtool \
        libblocksruntime-dev

COPY --from=builder-libtapi /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-xar /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-libdispatch /usr/arm-apple-darwin11 /usr/arm-apple-darwin11

COPY --from=builder-libtapi /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
COPY --from=builder-xar /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
COPY --from=builder-libdispatch /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator

COPY --from=builder-libtapi /usr/arm64-ios-simulator /usr/arm64-ios-simulator
COPY --from=builder-xar /usr/arm64-ios-simulator /usr/arm64-ios-simulator
COPY --from=builder-libdispatch /usr/arm64-ios-simulator /usr/arm64-ios-simulator

RUN git clone https://github.com/tpoechtrager/cctools-port.git  --depth 1 --branch 1009.2-ld64-907

RUN cd cctools-port/cctools && \
    git clean -xfd && \
    ./autogen.sh && \
    ./configure \
        --prefix=/usr/arm-apple-darwin11 \
        --target arm-apple-darwin11 \
        --with-libtapi=/usr/arm-apple-darwin11 \
        --with-libxar=/usr/arm-apple-darwin11 \
        --with-libdispatch=/usr/arm-apple-darwin11 \
      && \
    make && \
    make install

RUN cd cctools-port/cctools && \
    git clean -xfd && \
    ./autogen.sh && \
    ./configure \
        --prefix=/usr/x86_64-ios-simulator \
        --target x86_64-ios-simulator \
        --with-libtapi=/usr/x86_64-ios-simulator \
        --with-libxar=/usr/x86_64-ios-simulator \
        --with-libdispatch=/usr/x86_64-ios-simulator \
      && \
    make && \
    make install

RUN cd cctools-port/cctools && \
    git clean -xfd && \
    ./autogen.sh && \
    ./configure \
        --prefix=/usr/arm64-ios-simulator \
        --target arm64-ios-simulator \
        --with-libtapi=/usr/arm64-ios-simulator \
        --with-libxar=/usr/arm64-ios-simulator \
        --with-libdispatch=/usr/arm64-ios-simulator \
      && \
    make && \
    make install

COPY wrapper.c /wrapper.c
RUN cc -O2 -Wall -Wextra -pedantic /wrapper.c -D IOS -DARCH=arm64 -o /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang && \
    ln -sf /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang++ && \
    ln -sf /usr/arm-apple-darwin11/bin/arm-apple-darwin11-install_name_tool /usr/arm-apple-darwin11/bin/install_name_tool

RUN cc -O2 -Wall -Wextra -pedantic /wrapper.c -D IOS_SIMULATOR -DARCH=x86_64 -o /usr/x86_64-ios-simulator/bin/x86_64-ios-simulator-clang && \
    ln -sf /usr/x86_64-ios-simulator/bin/x86_64-ios-simulator-clang /usr/x86_64-ios-simulator/bin/x86_64-ios-simulator-clang++ && \
    ln -sf /usr/x86_64-ios-simulator/bin/x86_64-ios-simulator-install_name_tool /usr/x86_64-ios-simulator/bin/install_name_tool

RUN cc -O2 -Wall -Wextra -pedantic /wrapper.c -D IOS_SIMULATOR -DARCH=arm64 -o /usr/arm64-ios-simulator/bin/arm64-ios-simulator-clang && \
    ln -sf /usr/arm64-ios-simulator/bin/arm64-ios-simulator-clang /usr/arm64-ios-simulator/bin/arm64-ios-simulator-clang++ && \
    ln -sf /usr/arm64-ios-simulator/bin/arm64-ios-simulator-install_name_tool /usr/arm64-ios-simulator/bin/install_name_tool

################s
##### ldid #####
################
FROM base as builder-ldid

RUN git clone https://github.com/tpoechtrager/ldid.git && \
    cd ldid && \
    git checkout 4bf8f4d60384a0693dbbe2084ce62a35bfeb87ab

RUN cd ldid && \
    git clean -xfd && \
    make INSTALLPREFIX=/usr/arm-apple-darwin11 install

RUN cd ldid && \
    git clean -xfd && \
    make INSTALLPREFIX=/usr/x86_64-ios-simulator install

RUN cd ldid && \
    git clean -xfd && \
    make INSTALLPREFIX=/usr/arm64-ios-simulator install

###############
##### SDK #####
###############
FROM base as builder-sdk

COPY sdk.tar /sdk.tar

RUN mkdir -p /usr/arm-apple-darwin11/sdk && \
    tar -xf sdk.tar -C /usr/arm-apple-darwin11/sdk --strip-components 1 iPhoneOS.sdk && \
    mkdir -p /usr/arm-apple-darwin11/sdk/usr/local && \
    ln -sf /usr/arm-apple-darwin11/include /usr/arm-apple-darwin11/sdk/usr/local/include && \
    ln -sf /usr/arm-apple-darwin11/lib /usr/arm-apple-darwin11/sdk/usr/local/lib

RUN mkdir -p /usr/x86_64-ios-simulator/sdk && \
    tar -xf sdk.tar -C /usr/x86_64-ios-simulator/sdk --strip-components 1 iPhoneSimulator.sdk && \
    mkdir -p /usr/x86_64-ios-simulator/sdk/usr/local && \
    ln -sf /usr/x86_64-ios-simulator/include /usr/x86_64-ios-simulator/sdk/usr/local/include && \
    ln -sf /usr/x86_64-ios-simulator/lib /usr/x86_64-ios-simulator/sdk/usr/local/lib

RUN mkdir -p /usr/arm64-ios-simulator/sdk && \
    tar -xf sdk.tar -C /usr/arm64-ios-simulator/sdk --strip-components 1 iPhoneSimulator.sdk && \
    mkdir -p /usr/arm64-ios-simulator/sdk/usr/local && \
    ln -sf /usr/arm64-ios-simulator/include /usr/arm64-ios-simulator/sdk/usr/local/include && \
    ln -sf /usr/arm64-ios-simulator/lib /usr/arm64-ios-simulator/sdk/usr/local/lib

##################
##### openmp #####
##################
FROM base as builder-openmp

RUN git clone https://github.com/llvm/llvm-project && \
    cd /llvm-project && \
    git checkout 3b5b5c1ec4a3095ab096dd780e84d7ab81f3d7ff

RUN export DEBIAN_FRONTEND=noninteractive; apt-get install -y libstdc++-12-dev cmake

ENV PATH=/usr/arm-apple-darwin11/bin/:/usr/x86_64-ios-simulator/bin/:/usr/arm64-ios-simulator/bin/:$PATH

COPY *.patch toolchain-ios.cmake toolchain-ios-sim-x86_64.cmake toolchain-ios-sim-arm64.cmake /

COPY --from=builder-sdk /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-cctools /usr/arm-apple-darwin11 /usr/arm-apple-darwin11

COPY --from=builder-sdk /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
COPY --from=builder-cctools /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator

COPY --from=builder-sdk /usr/arm64-ios-simulator /usr/arm64-ios-simulator
COPY --from=builder-cctools /usr/arm64-ios-simulator /usr/arm64-ios-simulator

RUN cd /llvm-project/openmp && \
    git clean -xfd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain-ios.cmake \
          -DLIBOMP_ENABLE_SHARED=off \
          -DCMAKE_INSTALL_PREFIX=/usr/arm-apple-darwin11 \
          -DLIBOMP_ARCH=arm -DLIBOMP_OMPT_SUPPORT=OFF \
          -Wno-dev .. && \
    make && \
    make install

RUN cd /llvm-project/openmp && \
    git clean -xfd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain-ios-sim-x86_64.cmake \
          -DLIBOMP_ENABLE_SHARED=off \
          -DCMAKE_INSTALL_PREFIX=/usr/x86_64-ios-simulator \
          -DLIBOMP_ARCH=x86_64 -DLIBOMP_OMPT_SUPPORT=OFF \
          -Wno-dev .. && \
    make && \
    make install

RUN cd /llvm-project/openmp && \
    git clean -xfd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain-ios-sim-arm64.cmake \
          -DLIBOMP_ENABLE_SHARED=off \
          -DCMAKE_INSTALL_PREFIX=/usr/arm64-ios-simulator \
          -DLIBOMP_ARCH=arm -DLIBOMP_OMPT_SUPPORT=OFF \
          -Wno-dev .. && \
    make && \
    make install

################################################
##################### MAIN #####################
################################################
FROM ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang unzip

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=$PATH:/opt/cmake/bin

COPY --from=builder-cctools /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-ldid /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-openmp /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-sdk /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
ENV PATH=$PATH:/usr/arm-apple-darwin11/bin/

COPY --from=builder-cctools /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
COPY --from=builder-ldid /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
COPY --from=builder-openmp /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
COPY --from=builder-sdk /usr/x86_64-ios-simulator /usr/x86_64-ios-simulator
ENV PATH=$PATH:/usr/x86_64-ios-simulator/bin/

COPY --from=builder-cctools /usr/arm64-ios-simulator /usr/arm64-ios-simulator
COPY --from=builder-ldid /usr/arm64-ios-simulator /usr/arm64-ios-simulator
COPY --from=builder-openmp /usr/arm64-ios-simulator /usr/arm64-ios-simulator
COPY --from=builder-sdk /usr/arm64-ios-simulator /usr/arm64-ios-simulator
ENV PATH=$PATH:/usr/arm64-ios-simulator/bin/

COPY toolchain-ios.cmake /usr/arm-apple-darwin11/toolchain.cmake
COPY toolchain-ios-sim-x86_64.cmake /usr/x86_64-ios-simulator/toolchain.cmake
COPY toolchain-ios-sim-arm64.cmake /usr/arm64-ios-simulator/toolchain.cmake
