#################
##### cmake #####
#################
FROM ubuntu:18.04 as builder-cmake

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

ARG CMAKE_VERSION=3.14.5

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
FROM ubuntu:18.04 as builder-libtapi

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

RUN git clone https://github.com/tpoechtrager/apple-libtapi.git --depth 1 --branch 1000.10.8

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=/opt/cmake/bin:$PATH

RUN cd apple-libtapi && \
    MAKEFLAGS=-j$(nproc) INSTALLPREFIX=/usr/arm-apple-darwin11 \
        ./build.sh && ./install.sh

###############
##### xar #####
###############
FROM ubuntu:18.04 as builder-xar

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

RUN wget https://github.com/downloads/mackyle/xar/xar-1.6.1.tar.gz && \
    tar -xf xar-1.6.1.tar.gz && \
    cd xar-1.6.1 && \
    ac_cv_lib_crypto_OpenSSL_add_all_ciphers=yes ./configure --prefix=/usr/arm-apple-darwin11 && \
    make -j$(nproc) && \
    make install

###################
##### cctools #####
###################
FROM ubuntu:18.04 as builder-cctools

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

COPY --from=builder-libtapi /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-xar /usr/arm-apple-darwin11 /usr/arm-apple-darwin11

RUN git clone https://github.com/tpoechtrager/cctools-port.git --depth 1 && \
    cd cctools-port/cctools && \
    ./configure --prefix=/usr/arm-apple-darwin11 --target arm-apple-darwin11 --with-libtapi=/usr/arm-apple-darwin11 --with-libxar=/usr/arm-apple-darwin11 && \
    make -j$(nproc) && \
    make install

COPY wrapper.c /wrapper.c
RUN cc -O2 -Wall -Wextra -pedantic /wrapper.c -o /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang

RUN ln -sf /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang /usr/arm-apple-darwin11/bin/arm-apple-darwin11-clang++
RUN ln -sf /usr/arm-apple-darwin11/bin/arm-apple-darwin11-install_name_tool /usr/arm-apple-darwin11/bin/install_name_tool

################s
##### ldid #####
################
FROM ubuntu:18.04 as builder-ldid

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

RUN git clone https://github.com/tpoechtrager/ldid.git --depth 1 --branch master
RUN cd ldid && \
    make -j$(nproc) INSTALLPREFIX=/usr/arm-apple-darwin11 install

###############
##### SDK #####
###############
FROM ubuntu:18.04 as builder-sdk

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

COPY iPhoneOS.sdk.tar /
RUN mkdir -p /usr/arm-apple-darwin11/sdk && \
    tar -xf iPhoneOS.sdk.tar -C /usr/arm-apple-darwin11/sdk

RUN mkdir -p /usr/arm-apple-darwin11/sdk/usr/local && \
    ln -sf /usr/arm-apple-darwin11/include /usr/arm-apple-darwin11/sdk/usr/local/include && \
    ln -sf /usr/arm-apple-darwin11/lib /usr/arm-apple-darwin11/sdk/usr/local/lib

##################
##### openmp #####
##################
FROM ubuntu:18.04 as builder-openmp

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

ARG OPENMP_REVISION=07c5582c3b767e3f55753c493905e99498862441

RUN wget https://github.com/llvm-project/openmp/archive/${OPENMP_REVISION}.zip && \
    unzip ${OPENMP_REVISION}.zip

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=/opt/cmake/bin:$PATH

COPY --from=builder-cctools /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-sdk /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
ENV PATH=/usr/arm-apple-darwin11/bin/:$PATH

COPY *.patch toolchain-ios.cmake /

RUN cd /openmp-${OPENMP_REVISION} && \
    patch -p1 -i /openmp-ios-classic-environ.patch && \
    patch -p1 -i /openmp-kmp_unnamed_critical_addr-clang-arm-build-fix.patch && \
    patch -p1 -i /openmp-atomic-drop-complex-div.patch && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=/toolchain-ios.cmake \
          -DLIBOMP_ENABLE_SHARED=off \
          -DCMAKE_INSTALL_PREFIX=/usr/arm-apple-darwin11 \
          -Wno-dev .. && \
    make -j$(nproc) && \
    make install && \
    rm -rf /openmp-${OPENMP_REVISION}

################################################
##################### MAIN #####################
################################################
FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive; apt-get update && apt-get install -y \
        software-properties-common wget curl apt-transport-https vim git build-essential clang libxml2-dev libssl-dev unzip jq

COPY --from=builder-cctools /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-ldid /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-openmp /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
COPY --from=builder-sdk /usr/arm-apple-darwin11 /usr/arm-apple-darwin11
ENV PATH=/usr/arm-apple-darwin11/bin/:$PATH

COPY --from=builder-cmake /opt/cmake /opt/cmake
ENV PATH=/opt/cmake/bin:$PATH

COPY toolchain-ios.cmake /usr/arm-apple-darwin11/
