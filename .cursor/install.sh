#!/usr/bin/env bash
# Cloud Agent bootstrap for the VFD Hub Flutter app.
# Self-contained and idempotent: installs the Flutter SDK and the system
# libraries needed to build/run the Linux desktop target and the unit tests,
# then resolves dependencies and generates sources. Safe to run repeatedly
# and against a warm snapshot (it skips work that is already done).
set -euo pipefail

# Flutter 3.24.0 / Dart 3.5.0 matches this project's .metadata revision
# (80c2e84...) and the committed pubspec.lock.
FLUTTER_VERSION="3.24.0"
FLUTTER_DIR="$HOME/flutter"
FLUTTER_TARBALL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# --- System libraries -------------------------------------------------------
# clang/cmake/ninja/GTK: Linux desktop build toolchain.
# libsqlite3: loaded at runtime by sqflite_common_ffi (used by the unit tests).
# libsecret: backend for flutter_secure_storage on Linux.
if ! ldconfig -p | grep -q 'libsqlite3.so ' \
    || ! command -v clang >/dev/null 2>&1 \
    || ! ldconfig -p | grep -q 'libgtk-3.so '; then
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    curl xz-utils git \
    clang cmake ninja-build pkg-config build-essential \
    libgtk-3-dev liblzma-dev libstdc++-14-dev libsecret-1-dev \
    libsqlite3-0 libsqlite3-dev
fi

# --- Flutter SDK ------------------------------------------------------------
if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION} to ${FLUTTER_DIR} ..."
  tmp_tarball="$(mktemp --suffix=.tar.xz)"
  curl -fsSL -o "$tmp_tarball" "$FLUTTER_TARBALL"
  rm -rf "$FLUTTER_DIR"
  tar -xf "$tmp_tarball" -C "$HOME"
  rm -f "$tmp_tarball"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Persist Flutter on PATH for the agent's interactive shells.
if ! grep -q 'flutter/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Flutter shells out to git internally; mark its dir and the workspace safe.
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true
git config --global --add safe.directory /workspace 2>/dev/null || true

flutter config --no-analytics >/dev/null 2>&1 || true
flutter config --enable-linux-desktop >/dev/null 2>&1 || true

# Regenerate the Linux desktop runner scaffolding (linux/ is not committed to
# this mobile-first repo). Idempotent; also resolves dependencies.
flutter create --platforms=linux --project-name vfd_param_app . >/dev/null

# Ensure locked dependencies from pubspec.lock are fetched.
flutter pub get

# Generate localization sources (pubspec.yaml sets generate: true).
flutter gen-l10n >/dev/null 2>&1 || true

echo "VFD Hub environment ready."
flutter --version | head -1
