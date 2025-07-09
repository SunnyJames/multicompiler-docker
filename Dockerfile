
# Dockerfile based on instructions at: https://github.com/securesystemslab/multicompiler

# Use Ubuntu 18.04 as base (adjust if needed)
FROM ubuntu:18.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages, including libssl1.0-dev for older OpenSSL.
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  git \
  python2.7 \
  zlib1g-dev \
  libedit-dev \
  libncurses5-dev \
  swig \
  libxml2-dev \
  curl \
  wget \
  flex \
  bison \
  texinfo \
  patch \
  libssl1.0.0 \
  libssl1.0-dev \
  && apt-get clean

  #binutils \
  #binutils-dev \

# Make sure python points to python2.7
RUN ln -sf /usr/bin/python2.7 /usr/bin/python

# Create symlinks so that CMake finds OpenSSL 1.0 in the expected locations.
# On Ubuntu, the OpenSSL includes are in /usr/include/openssl, so we link that to /usr/include/openssl-1.0.
RUN ln -s /usr/include/openssl /usr/include/openssl-1.0 || true

# The libcrypto library might be in /usr/lib/x86_64-linux-gnu; create a symlink in /usr/lib.
#RUN ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.1.0.0 || true
RUN ln -s /usr/lib/aarch64-linux-gnu/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.1.0.0 || true

# Set working directory
WORKDIR /opt

# Shallow clone the git repositories needed 
RUN git clone --depth 1 https://github.com/securesystemslab/multicompiler.git llvm-src
RUN git clone --depth 1 https://github.com/securesystemslab/multicompiler-clang.git llvm-src/tools/clang
RUN git clone --depth 1 https://github.com/securesystemslab/multicompiler-compiler-rt.git llvm-src/projects/compiler-rt
RUN git clone --depth 1 https://github.com/securesystemslab/poolalloc.git llvm-src/projects/poolalloc

#Use binutils 2.26
RUN git clone --depth 1 https://github.com/securesystemslab/binutils.git binutils-src

#Compile binutils with the ld.gold plugin using the SecureSystemsLab patched binutils
RUN mkdir /opt/binutils-build 
WORKDIR /opt/binutils-build
RUN ../binutils-src/configure --prefix=/opt/binutils-install \
             	--enable-gold \
             	--enable-plugins \
             	--disable-werror \
	     	--disable-gdb \
 	     	--disable-sim \
		--disable-nls
RUN make -j$(nproc)
RUN make install

#Setup build directories
WORKDIR /opt/llvm-src
RUN mkdir build 
WORKDIR /opt/llvm-src/build
RUN cmake .. \
  -DLLVM_TARGETS_TO_BUILD="AArch64" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/opt/llvm-install \
  -DLLVM_BINUTILS_INCDIR=/opt/binutils-install/include \
  -DCMAKE_LINKER=/opt/binutils-install/bin/ld.gold \
  -DOPENSSL_INCLUDE_DIR=/usr/include/openssl-1.0 \
  -DOPENSSL_CRYPTO_LIBRARY=/usr/lib/libcrypto.so.1.0.0

RUN make -j$(nproc)
RUN make install

# Add the build binarires (including clang) to the PATH
ENV PATH="/opt/llvm-install/bin:${PATH}"

# Default command: launch a bash shell
CMD ["/bin/bash"]
