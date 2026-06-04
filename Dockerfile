# Build:
#   docker build -t ibex-dev .
#
# Run:
#   docker run --rm -it -v "$PWD:/work" -w /work ibex-dev bash

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# ---- OS deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf automake autotools-dev \
    bash \
    bc \
    bison \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    curl \
    device-tree-compiler \
    flex \
    gawk \
    gdb \
    git \
    gnupg \
    libexpat1-dev \
    libffi-dev \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libssl-dev \
    libtool \
    libz-dev \
    libelf-dev \
    make \
    ninja-build \
    patchutils \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    srecord \
    texinfo \
    verilator \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# ---- Python tooling + FuseSoC ----
RUN pip3 install --no-cache-dir -U pip setuptools wheel \
 && pip3 install --no-cache-dir -U fusesoc

# ---- Install Ibex python requirements at image build time ----
# This assumes you run `docker build` from the Ibex repo root (so python-requirements.txt is present).
COPY python-requirements.txt /tmp/python-requirements.txt
RUN pip3 install --no-cache-dir -U -r /tmp/python-requirements.txt \
 && rm -f /tmp/python-requirements.txt

# ---- Build riscv-gnu-toolchain (newlib) for RV32IMC + Zicsr/Zifencei, soft-float, NO multilib ----
ARG RISCV_PREFIX=/opt/riscv
ENV RISCV=${RISCV_PREFIX}
ENV PATH=${RISCV_PREFIX}/bin:${PATH}

ARG RISCV_GNU_TOOLCHAIN_REF=
RUN git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git /tmp/riscv-gnu-toolchain \
 && cd /tmp/riscv-gnu-toolchain \
 && if [[ -n "${RISCV_GNU_TOOLCHAIN_REF}" ]]; then git checkout "${RISCV_GNU_TOOLCHAIN_REF}"; fi \
 && git submodule update --init --recursive \
 && ./configure \
      --prefix="${RISCV_PREFIX}" \
      --with-arch=rv32imc_zicsr_zifencei \
      --with-abi=ilp32 \
      --disable-multilib \
 && make -j"$(nproc)" newlib \
 && rm -rf /tmp/riscv-gnu-toolchain

# Convenience defaults for bare-metal builds
ENV RISCV_MARCH=rv32imc_zicsr_zifencei
ENV RISCV_MABI=ilp32
ENV RISCV_CFLAGS="-march=${RISCV_MARCH} -mabi=${RISCV_MABI}"
ENV RISCV_CXXFLAGS="${RISCV_CFLAGS}"

WORKDIR /work
CMD ["bash"]