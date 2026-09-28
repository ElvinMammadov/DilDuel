#!/bin/sh

set -e

FLUTTER_VERSION="3.35.7"
FLUTTER_DIR="$HOME/flutter"

echo "==> Installing Flutter $FLUTTER_VERSION"
git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR"

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter --version

echo "==> Running flutter pub get"
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

echo "==> Running pod install"
cd ios
pod install
