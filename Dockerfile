# Dockerfile

FROM ubuntu:22.04

# Install basic tools
RUN apt-get update && apt-get install -y \
    curl git unzip build-essential \
    cmake ninja-build python3 python3-pip \
    openjdk-11-jdk \
    libc6-dev-i386 libstdc++6 \
    pkg-config zlib1g-dev \
    gcc-multilib g++-multilib \
    ca-certificates qemu-user-static \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_NDK_VERSION=r28
ENV ANDROID_NDK_ROOT=/opt/android-ndk
ENV PATH="$ANDROID_NDK_ROOT:$PATH"

# Install Android NDK
RUN wget https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip -O /tmp/ndk.zip && \
    unzip /tmp/ndk.zip -d /opt && \
    mv /opt/android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_ROOT} && \
    rm /tmp/ndk.zip

# Install Rust
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:$PATH"
RUN rustup target add arm-linux-androideabi

# Install Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && npm install -g yarn

WORKDIR /project

CMD ["bash"]
