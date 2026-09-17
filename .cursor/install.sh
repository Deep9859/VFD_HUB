#!/usr/bin/env bash
# Cloud Agent bootstrap for the VFD Hub Flutter app.
# Idempotent: safe to run repeatedly and against a warm snapshot.
set -euo pipefail

export PATH="$HOME/flutter/bin:$PATH"

# System libraries required to build/run the Linux desktop target and to load
# the sqlite3 shared library used by sqflite_common_ffi (needed by unit tests).
# The base snapshot already contains these; reinstall only if something is missing.
if ! ldconfig -p | grep -q 'libsqlite3.so ' || ! command -v clang >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    clang cmake ninja-build pkg-config build-essential \
    libgtk-3-dev liblzma-dev libstdc++-14-dev libsecret-1-dev \
    libsqlite3-0 libsqlite3-dev
fi

flutter config --no-analytics >/dev/null 2>&1 || true
flutter config --enable-linux-desktop >/dev/null 2>&1 || true

# Regenerate the Linux desktop runner scaffolding (linux/ is not committed to
# this mobile-first repo). This is idempotent and also resolves dependencies.
flutter create --platforms=linux --project-name vfd_param_app . >/dev/null

# Ensure locked dependencies from pubspec.lock are fetched.
flutter pub get

# Generate localization sources (pubspec.yaml sets generate: true).
flutter gen-l10n >/dev/null 2>&1 || true

echo "VFD Hub environment ready."
flutter --version | head -1
