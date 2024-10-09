FROM ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y git wget build-essential libxml2-dev libssl-dev autoconf cpio libssl-dev libz-dev liblzma-dev

ENV LD_LIBRARY_PATH=/usr/local/lib/

COPY xar-*.patch /

RUN git clone https://github.com/mackyle/xar && \
    cd xar && \
    git checkout 66d451dab1ef859dd0c83995f2379335d35e53c9

RUN git clone https://github.com/NiklasRosenstein/pbzx && \
    cd pbzx && \
    git checkout bf536e167f2e514866f91d7baa0df1dff5a13711

RUN cd xar/xar && \
    git clean -xfd && \
    patch -p2 < /xar-compilation-fixes.patch && \
    ./autogen.sh \
        --prefix=/usr \
        CFLAGS="-I/usr/include" \
        LDFLAGS="-L/usr/lib/x86_64-linux-gnu/" && \
    ./configure && \
    make -j$(nproc) && \
    make install

RUN cd pbzx && \
    gcc pbzx.c -llzma -lxar -o /usr/local/bin/pbzx

COPY _entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
