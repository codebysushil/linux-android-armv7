# syntax=docker/dockerfile:1

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# ============================================================
# Versions
# ============================================================

ARG ANDROID_NDK_VERSION=r27c

# ============================================================
# Environment
# ============================================================

ENV CARGO_HOME=/root/.cargo \
    RUSTUP_HOME=/root/.rustup \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_NDK_ROOT=/opt/android-ndk \
    ANDROID_NDK_HOME=/opt/android-ndk \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

ENV PATH="/root/.cargo/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/build-tools/35.0.0:${ANDROID_NDK_ROOT}:${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:${PATH}"

# ============================================================
# System dependencies
# ============================================================

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        unzip \
        zip \
        xz-utils \
        file \
        pkg-config \
        build-essential \
        cmake \
        ninja-build \
        clang \
        lld \
        llvm \
        python3 \
        python3-pip \
        openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Android SDK Command Line Tools
# ============================================================

ARG ANDROID_CMDLINE_TOOLS=13114758

RUN mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools" \
    && wget -q \
        "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" \
        -O /tmp/cmdline-tools.zip \
    && unzip -q \
        /tmp/cmdline-tools.zip \
        -d "${ANDROID_SDK_ROOT}/cmdline-tools" \
    && mv \
        "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" \
        "${ANDROID_SDK_ROOT}/cmdline-tools/latest" \
    && rm -f /tmp/cmdline-tools.zip

# ============================================================
# Android SDK
# ============================================================

RUN yes | sdkmanager --licenses >/dev/null 2>&1 || true

RUN sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;35.0.0"

# ============================================================
# Android NDK
# ============================================================

RUN wget -q \
        "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" \
        -O /tmp/android-ndk.zip \
    && unzip -q \
        /tmp/android-ndk.zip \
        -d /opt \
    && mv \
        "/opt/android-ndk-${ANDROID_NDK_VERSION}" \
        "${ANDROID_NDK_ROOT}" \
    && rm -f /tmp/android-ndk.zip

# ============================================================
# Verify Android NDK
# ============================================================

RUN test -f "${ANDROID_NDK_ROOT}/source.properties" \
    && test -f "${ANDROID_NDK_ROOT}/ndk-build"

# ============================================================
# Rust
# ============================================================

RUN curl \
        --proto '=https' \
        --tlsv1.2 \
        -sSf \
        https://sh.rustup.rs \
    | sh -s -- \
        -y \
        --profile minimal

# ============================================================
# Rust targets
# ============================================================

RUN rustup target add \
        x86_64-unknown-linux-gnu \
        i686-unknown-linux-gnu \
        aarch64-unknown-linux-gnu \
        armv7-unknown-linux-gnueabihf \
        x86_64-pc-windows-gnu \
        i686-pc-windows-gnu \
        aarch64-linux-android \
        armv7-linux-androideabi \
        x86_64-linux-android \
        i686-linux-android

# ============================================================
# Cargo Android linker configuration
# ============================================================

RUN mkdir -p "${CARGO_HOME}" \
    && cat > "${CARGO_HOME}/config.toml" <<'EOF'

[target.aarch64-linux-android]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang"

[target.armv7-linux-androideabi]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi24-clang"

[target.x86_64-linux-android]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android24-clang"

[target.i686-linux-android]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android24-clang"

EOF

# ============================================================
# Node.js
# ============================================================

RUN curl -fsSL \
        https://deb.nodesource.com/setup_22.x \
        | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g corepack \
    && corepack enable \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Verification
# ============================================================

RUN echo "========================================" \
    && echo "System" \
    && echo "========================================" \
    && uname -a \
    && echo \
    && echo "========================================" \
    && echo "Java" \
    && echo "========================================" \
    && java -version \
    && echo \
    && echo "========================================" \
    && echo "Rust" \
    && echo "========================================" \
    && rustc --version \
    && cargo --version \
    && rustup --version \
    && echo \
    && echo "========================================" \
    && echo "Node.js" \
    && echo "========================================" \
    && node --version \
    && npm --version \
    && echo \
    && echo "========================================" \
    && echo "C/C++ Toolchain" \
    && echo "========================================" \
    && gcc --version \
    && clang --version \
    && cmake --version \
    && ninja --version \
    && echo \
    && echo "========================================" \
    && echo "Android SDK" \
    && echo "========================================" \
    && sdkmanager --version \
    && adb --version \
    && echo \
    && echo "========================================" \
    && echo "Android NDK" \
    && echo "========================================" \
    && "${ANDROID_NDK_ROOT}/ndk-build" --version \
    && echo \
    && echo "========================================" \
    && echo "Rust Targets" \
    && echo "========================================" \
    && rustup target list --installed \
    && echo \
    && echo "========================================" \
    && echo "Android Linkers" \
    && echo "========================================" \
    && test -x "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang" \
    && test -x "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi24-clang" \
    && test -x "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android24-clang" \
    && test -x "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android24-clang" \
    && echo "Android linkers: OK"

# ============================================================
# Project
# ============================================================

WORKDIR /workspace

CMD ["bash"]        lld \
        llvm \
        python3 \
        python3-pip \
        openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Android SDK command-line tools
# ============================================================

ARG ANDROID_CMDLINE_TOOLS=13114758

RUN mkdir -p /opt/android-sdk/cmdline-tools \
    && wget -q \
       "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" \
       -O /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip \
       -d /opt/android-sdk/cmdline-tools \
    && mv \
       /opt/android-sdk/cmdline-tools/cmdline-tools \
       /opt/android-sdk/cmdline-tools/latest \
    && rm -f /tmp/cmdline-tools.zip

# ============================================================
# Android SDK
# ============================================================

RUN yes | sdkmanager --licenses >/dev/null 2>&1 || true

RUN sdkmanager \
        "platform-tools" \
        "platforms;android-35" \
        "build-tools;35.0.0"

# ============================================================
# Android NDK
# ============================================================

RUN wget -q \
        "https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux.zip" \
        -O /tmp/android-ndk.zip \
    && unzip -q /tmp/android-ndk.zip -d /opt \
    && mv \
        "/opt/android-ndk-${ANDROID_NDK_VERSION}" \
        "${ANDROID_NDK_ROOT}" \
    && rm -f /tmp/android-ndk.zip

# ============================================================
# Rust
# ============================================================

RUN curl --proto '=https' \
        --tlsv1.2 \
        -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal

# ============================================================
# Rust Android targets
# ============================================================

RUN rustup target add \
        aarch64-linux-android \
        armv7-linux-androideabi \
        x86_64-linux-android \
        i686-linux-android

# ============================================================
# Cargo Android linker configuration
# ============================================================

RUN mkdir -p /root/.cargo \
    && cat > /root/.cargo/config.toml <<'EOF'
[target.aarch64-linux-android]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android24-clang"

[target.armv7-linux-androideabi]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi24-clang"

[target.x86_64-linux-android]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/x86_64-linux-android24-clang"

[target.i686-linux-android]
linker = "/opt/android-ndk/toolchains/llvm/prebuilt/linux-x86_64/bin/i686-linux-android24-clang"
EOF

# ============================================================
# Node.js
# ============================================================

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g corepack \
    && corepack enable \
    && rm -rf /var/lib/apt/lists/*

# ============================================================
# Verification
# ============================================================

RUN rustc --version \
    && cargo --version \
    && node --version \
    && npm --version \
    && clang --version \
    && cmake --version \
    && java -version \
    && sdkmanager --version \
    && ndk-build --version

WORKDIR /workspace

CMD ["bash"]
