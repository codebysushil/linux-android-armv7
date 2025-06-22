## 🐳 Android ARMv7 Builder Docker Image

[![Docker Image (linux-android-armv7)](https://github.com/codebysushil/linux-android-armv7/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/codebysushil/linux-android-armv7/actions/workflows/docker-publish.yml)

This repository provides a cross-compilation Docker image for building Rust + Node.js native modules targeting `linux-android-armv7` (Android NDK `armeabi-v7a` ABI).

---

#### 📦 Image Features

- ✅ Ubuntu 22.04 base
- ✅ Android NDK r27c 
- ✅ Rust toolchain + `armv7-linux-androideabi` target
- ✅ Node.js (v18 LTS) + Yarn
- ✅ QEMU support for cross-arch compatibility

---

### 📥 Usage

#### Pull the image

```ru
docker pull ghcr.io/codebysushil/linux-android-armv7-builder:latest
```

#### Release
target `armv7` or `armeabi` CPU architecture

**OS:** Android
**ARCH:** armv7 or aarch64

for armv7a (32-bit)
```ru
cargo build --target armeabi-linux-androideabi --release

cargo build --target armv7-linux-androideabi --release
```

for armv8a or aarch64 (64-bit)
```ru
cargo build --target aarch64-linux-android --release
```

#### Example

```yml
- target: armeabi-linux-androideabi
  strip: llvm-strip
  image: ghcr.io/codebysushil/linux-android-armv7/linux-android-armv7: latest@sha256:90632d805b53d78e5f0fe98c0ac8ceb3528b344a00b024106b66919fbf91d887

- target: aarch64-linux-andeoid
  strip: llvm-strip
  image: ghcr.io/napi-rs/napi-rs/nodejs-rust:lts-debian-aarch64
```
