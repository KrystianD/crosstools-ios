#################
##### cmake #####
#################
FROM ubuntu:22.04 as builder-cmake

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

ARG CMAKE_VERSION=3.18.0

RUN mkdir cmake && cd cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz && \
    tar -xf cmake-${CMAKE_VERSION}.tar.gz && \
    cd cmake-${CMAKE_VERSION} && \
    export MAKEFLAGS="-j$(nproc)" && \
    ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX=/opt/cmake && \
    make && \
    make install && \
    rm -rf /root/cmake

###################
##### libtapi #####
###################
FROM ubuntu:22.04 as builder-libtapi

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

RUN git clone https://github.com/tpoechtrager/apple-libtapi.git --depth 1 --branch 1300.6.5

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=/opt/cmake/bin:$PATH

RUN cd apple-libtapi && \
    MAKEFLAGS=-j$(nproc) INSTALLPREFIX=/usr/arm-apple-darwin11 \
        ./build.sh && ./install.sh

RUN cd apple-libtapi && \
    git clean -xfd && \
    MAKEFLAGS=-j$(nproc) INSTALLPREFIX=/usr/x86_64-apple-darwin11 \
        ./build.sh && ./install.sh

###############
##### xar #####
###############
FROM ubuntu:22.04 as builder-xar

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq \
        autoconf libssl-dev libz-dev

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
    make -j$(nproc) && \
    make install

RUN cd xar/xar; \
    git clean -xfd; \
    ./autogen.sh \
        --prefix=/usr \
        CFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu/"; \
    ./configure --prefix=/usr/x86_64-apple-darwin11 && \
    make -j$(nproc) && \
    make install

FROM ubuntu:22.04 as builder-libdispatch

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=/opt/cmake/bin:$PATH

RUN git clone https://github.com/tpoechtrager/apple-libdispatch

RUN export DEBIAN_FRONTEND=noninteractive; apt-get install -y libblocksruntime-dev

RUN cd apple-libdispatch && \
    rm -rf build && mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=/usr/arm-apple-darwin11 \
      --with-blocks-runtime /usr/include \
      .. && \
    make && \
    make install

RUN cd apple-libdispatch && \
    rm -rf build && mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_INSTALL_PREFIX=/usr/x86_64-apple-darwin11 \
      --with-blocks-runtime /usr/include \
      .. && \
    make && \
    make install

###################
##### cctools #####
###################
FROM ubuntu:22.04 as builder-cctools

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential \
        clang libxml2-dev libssl-dev unzip jq autoconf automake libtool \
        libblocksruntime-dev

COPY --from=builder-libtapi /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-xar /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-libdispatch /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-libtapi /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11
COPY --from=builder-xar /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11
COPY --from=builder-libdispatch /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11

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
    make -j$(nproc) && \
    make install

RUN cd cctools-port/cctools && \
    git clean -xfd && \
    ./autogen.sh && \
    ./configure \
      --prefix=/usr/x86_64-apple-darwin11 \
        --target x86_64-apple-darwin11 \
        --with-libtapi=/usr/x86_64-apple-darwin11 \
        --with-libxar=/usr/x86_64-apple-darwin11 \
        --with-libdispatch=/usr/x86_64-apple-darwin11 \
      && \
    make -j$(nproc) && \
    make install

COPY wrapper.c /wrapper.c
RUN cc -O2 -Wall -Wextra -pedantic /wrapper.c -o /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang && \
    cc -O2 -Wall -Wextra -pedantic /wrapper.c -o /usr/x86_64-apple-darwin11/bin/x86_64-apple-darwin11-clang && \
    ln -sf /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang++ && \
    ln -sf /usr/arm-apple-darwin11/bin/arm-apple-darwin11-install_name_tool /usr/arm-apple-darwin11/bin/install_name_tool && \
    ln -sf /usr/x86_64-apple-darwin11/bin/x86_64-apple-darwin11-clang /usr/x86_64-apple-darwin11/bin/x86_64-apple-darwin11-clang++ && \
    ln -sf /usr/x86_64-apple-darwin11/bin/x86_64-apple-darwin11-install_name_tool /usr/x86_64-apple-darwin11/bin/install_name_tool

################s
##### ldid #####
################
FROM ubuntu:22.04 as builder-ldid

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

RUN git clone https://github.com/tpoechtrager/ldid.git --depth 1 --branch master && \
    cd ldid && \
    git checkout 4bf8f4d60384a0693dbbe2084ce62a35bfeb87ab

RUN cd ldid && \
    git clean -xfd && \
    make -j$(nproc) INSTALLPREFIX=/usr/arm-apple-darwin11 install

RUN cd ldid && \
    git clean -xfd && \
    make -j$(nproc) INSTALLPREFIX=/usr/x86_64-apple-darwin11 install

###############
##### SDK #####
###############
FROM ubuntu:22.04 as builder-sdk

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

COPY sdk.tar /
RUN mkdir -p /usr/arm-apple-darwin11/sdk && \
    mkdir -p /usr/x86_64-apple-darwin11/sdk && \
    tar -xf sdk.tar -C /usr/arm-apple-darwin11/sdk --strip-components 1 iPhoneOS.sdk && \
    tar -xf sdk.tar -C /usr/x86_64-apple-darwin11/sdk --strip-components 1 iPhoneSimulator.sdk

RUN mkdir -p /usr/arm-apple-darwin11/sdk/usr/local && \
    ln -sf /usr/arm-apple-darwin11/include /usr/arm-apple-darwin11/sdk/usr/local/include && \
    ln -sf /usr/arm-apple-darwin11/lib /usr/arm-apple-darwin11/sdk/usr/local/lib

RUN mkdir -p /usr/x86_64-apple-darwin11/sdk/usr/local && \
    ln -sf /usr/x86_64-apple-darwin11/include /usr/x86_64-apple-darwin11/sdk/usr/local/include && \
    ln -sf /usr/x86_64-apple-darwin11/lib /usr/x86_64-apple-darwin11/sdk/usr/local/lib

##################
##### openmp #####
##################
FROM ubuntu:22.04 as builder-openmp

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

ARG OPENMP_REVISION=56d941a8cede7c0d6aa4dc19e8f0b95de6f97e1b

RUN git clone https://github.com/llvm/llvm-project && \
    cd /llvm-project && \
    git checkout 3b5b5c1ec4a3095ab096dd780e84d7ab81f3d7ff

RUN export DEBIAN_FRONTEND=noninteractive; apt-get install -y libstdc++-12-dev cmake

COPY --from=builder-cctools /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-sdk /usr/arm-apple-darwin11 /usr/arm-apple-darwin11

COPY --from=builder-cctools /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11
COPY --from=builder-sdk /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11

ENV PATH=/usr/arm-apple-darwin11/bin/:/usr/x86_64-apple-darwin11/bin/:$PATH

COPY *.patch toolchain-ios.cmake toolchain-ios-sim.cmake /

RUN cd /llvm-project/openmp && \
    git clean -xfd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain-ios.cmake \
          -DLIBOMP_ENABLE_SHARED=off \
          -DCMAKE_INSTALL_PREFIX=/usr/arm-apple-darwin11 \
          -DLIBOMP_ARCH=arm -DLIBOMP_OMPT_SUPPORT=OFF \
          -Wno-dev .. && \
    make -j$(nproc) && \
    make install

RUN cd /llvm-project/openmp && \
    mkdir build2 && \
    cd build2 && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain-ios-sim.cmake \
          -DLIBOMP_ENABLE_SHARED=off \
          -DCMAKE_INSTALL_PREFIX=/usr/x86_64-apple-darwin11 \
          -DLIBOMP_ARCH=x86_64 -DLIBOMP_OMPT_SUPPORT=OFF \
          -Wno-dev .. && \
    make -j$(nproc) && \
    make install

################################################
##################### MAIN #####################
################################################
FROM ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

COPY --from=builder-cctools /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-ldid /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-openmp /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-sdk /usr/arm-apple-darwin11 /usr/arm-apple-darwin11

COPY --from=builder-cctools /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11
COPY --from=builder-ldid /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11
COPY --from=builder-openmp /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11
COPY --from=builder-sdk /usr/x86_64-apple-darwin11 /usr/x86_64-apple-darwin11

ENV PATH=/usr/arm-apple-darwin11/bin/:/usr/x86_64-apple-darwin11/bin/:$PATH

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=/opt/cmake/bin:$PATH

COPY toolchain-ios.cmake /usr/arm-apple-darwin11/toolchain.cmake
COPY toolchain-ios-sim.cmake /usr/x86_64-apple-darwin11/toolchain.cmake
