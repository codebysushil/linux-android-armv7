FROM rust:1.89-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    clang \
    lld \
    llvm \
    python3 \
    make \
    git \
    curl \
    unzip \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# Android SDK command-line tools
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=/opt/android-sdk

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    curl -L -o /tmp/cmdline-tools.zip \
      https://dl.google.com/android/repository/commandlinetools-linux-13114758_latest.zip && \
    unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools \
       ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm /tmp/cmdline-tools.zip

ENV PATH=${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}

RUN yes | sdkmanager --licenses >/dev/null || true && \
    sdkmanager \
      "platform-tools" \
      "platforms;android-35" \
      "build-tools;35.0.0" \
      "ndk;27.2.12479018"

ENV ANDROID_NDK_HOME=${ANDROID_SDK_ROOT}/ndk/27.2.12479018

# Rust Android ARMv7 target
RUN rustup target add armv7-linux-androideabi

WORKDIR /src

RUN git clone --depth 1 https://github.com/parcel-bundler/lightningcss.git .

# Android ARMv7 linker
ENV AR_armv7_linux_androideabi=\
/opt/android-sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar

ENV CC_armv7_linux_androideabi=\
/opt/android-sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi24-clang

ENV CXX_armv7_linux_androideabi=\
/opt/android-sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi24-clang++

ENV CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=\
/opt/android-sdk/ndk/27.2.12479018/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi24-clang

RUN cargo build --release \
    --target armv7-linux-androideabi

CMD ["bash"]
