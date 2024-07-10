FROM ubuntu:18.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y git wget build-essential libxml2-dev libssl-dev autoconf cpio libssl-dev libz-dev

COPY xar-*.patch /

RUN git clone https://github.com/mackyle/xar && \
    cd xar && \
    git checkout 66d451dab1ef859dd0c83995f2379335d35e53c9

RUN cd xar/xar && \
    git clean -xfd && \
    patch -p2 < /xar-compilation-fixes.patch && \
    patch -p2 < /xar-stdout-extract-memory-optimized.patch && \
    ./autogen.sh \
        --prefix=/usr \
        CFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu/" && \
    ./configure && \
    make -j$(nproc) && \
    make install

COPY pbzx.c /
RUN gcc pbzx.c -o /usr/local/bin/pbzx && \
    rm /pbzx.c

COPY _entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
