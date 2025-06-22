# 🐳 Android ARMv7 Builder Docker Image

[![Publish Docker Image (linux-android-armv7)](https://github.com/codebysushil/linux-android-armv7/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/codebysushil/linux-android-armv7/actions/workflows/docker-publish.yml)

This repository provides a cross-compilation Docker image for building Rust + Node.js native modules targeting `linux-android-armv7` (Android NDK `armeabi-v7a` ABI).

---

## 📦 Image Features

- ✅ Ubuntu 22.04 base
- ✅ Android NDK r28
- ✅ Rust toolchain + `armv7-linux-androideabi` target
- ✅ Node.js (v18 LTS) + Yarn
- ✅ QEMU support for cross-arch compatibility



## 📥 Usage

### Pull the image

```bash
docker pull ghcr.io/codebysushil/linux-android-armv7-builder:latest
```

## Release

```bash
cargo build --target armv7-linux-androideabi --release
```
