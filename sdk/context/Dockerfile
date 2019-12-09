FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y git wget build-essential libxml2-dev libssl-dev autoconf cpio

COPY xar-*.patch /
RUN wget https://github.com/downloads/mackyle/xar/xar-1.6.1.tar.gz && \
    tar -xf xar-1.6.1.tar.gz && \
    cd xar-1.6.1 && \
    patch -p2 < /xar-compilation-fixes.patch && \
    patch -p2 < /xar-stdout-extract-memory-optimized.patch && \
    ./autogen.sh && \
    make -j$(nproc) && make install && \
    rm /*.patch

COPY pbzx.c /
RUN gcc pbzx.c -o /usr/local/bin/pbzx && \
    rm /pbzx.c

COPY _entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
