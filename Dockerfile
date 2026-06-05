FROM ubuntu:24.04 AS toolchain-builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev libncurses-dev

RUN git clone --branch 2026.06.05 https://github.com/riscv/riscv-gnu-toolchain
WORKDIR /riscv-gnu-toolchain

RUN ./configure \
    --prefix=/opt/riscv \
    --with-arch=rv32imc_zicsr_zifencei \
    --with-abi=ilp32 \
    --disable-multilib \
    --disable-gdb && \
    make -j6

FROM ubuntu:24.04 AS verilator-builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git ca-certificates help2man perl python3 make autoconf g++ flex bison ccache libgoogle-perftools-dev libjemalloc-dev numactl perl-doc libfl2 libfl-dev

RUN git clone --branch v5.048 https://github.com/verilator/verilator
WORKDIR /verilator

RUN autoconf && \
    ./configure --prefix=/opt/verilator && \
    make -j"$(nproc)" && \
    make install

FROM ubuntu:24.04

COPY --from=toolchain-builder /opt/riscv /opt/riscv
COPY --from=verilator-builder /opt/verilator /opt/verilator

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    make \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/verilator/bin:/opt/riscv/bin:${PATH}"

CMD ["/bin/bash"]
