#!/bin/sh

set -e
set -x

FLUTTER_VERSION="3.35.7"
FLUTTER_DIR="$HOME/flutter"

echo "==> Architecture: $(uname -m)"

# Download prebuilt Flutter SDK (much faster than git clone)
if [ "$(uname -m)" = "arm64" ]; then
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_${FLUTTER_VERSION}-stable.zip"
else
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VERSION}-stable.zip"
fi

echo "==> Downloading Flutter from $FLUTTER_URL"
curl -L "$FLUTTER_URL" -o /tmp/flutter.zip

echo "==> Extracting Flutter"
unzip -q /tmp/flutter.zip -d "$HOME"

export PATH="$FLUTTER_DIR/bin:$PATH"
flutter --version

echo "==> Running flutter pub get"
cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

echo "==> Running pod install"
cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install
