#!/bin/bash
set -ex

PRODUCT_NAME="xcodeproj"
BUILD_DIR="build/linux"

# Use Swiftly on both macOS and Linux to ensure Swift 6.1.2 compatibility
export PATH="$HOME/.swiftly/bin:$PATH"
echo "Installing Swift 6.1.2 via Swiftly for Linux cross-compilation"

# Initialize Swiftly if not already done
if [ ! -f "$HOME/.swiftly/config.json" ]; then
    echo "Initializing Swiftly..."
    swiftly init
fi

swiftly install 6.1.2 || true
swiftly use 6.1.2

# Ensure we're using the Swiftly-installed Swift, not Xcode's
unset XCODE_TOOLCHAIN_IDENTIFIER
unset DEVELOPER_DIR

if ! swift sdk list | grep -q "swift-6.1.2-RELEASE_static-linux-0.0.1"; then
    swift sdk install \
        https://download.swift.org/swift-6.1.2-release/static-sdk/swift-6.1.2-RELEASE/swift-6.1.2-RELEASE_static-linux-0.0.1.artifactbundle.tar.gz \
        --checksum df0b40b9b582598e7e3d70c82ab503fd6fbfdff71fd17e7f1ab37115a0665b3b
fi

mkdir -p "$BUILD_DIR"

# Build for x86_64
swift build -c release --swift-sdk x86_64-swift-linux-musl --disable-sandbox
mkdir -p "$BUILD_DIR/x86_64"
cp ".build/release/$PRODUCT_NAME" "$BUILD_DIR/x86_64/"

# Clean before building for next arch
rm -rf .build

# Build for aarch64
swift build -c release --swift-sdk aarch64-swift-linux-musl --disable-sandbox
mkdir -p "$BUILD_DIR/aarch64"
cp ".build/release/$PRODUCT_NAME" "$BUILD_DIR/aarch64/"

VERSION=$(grep 'version:' Sources/xcodeproj-cli/Command.swift | sed 's/.*version: "\(.*\)".*/\1/')

cd "$BUILD_DIR/x86_64"
tar -czf "../${PRODUCT_NAME}-${VERSION}-linux-x86_64.tar.gz" "$PRODUCT_NAME"
cd -

cd "$BUILD_DIR/aarch64"
tar -czf "../${PRODUCT_NAME}-${VERSION}-linux-aarch64.tar.gz" "$PRODUCT_NAME"
cd -

cd "$BUILD_DIR"
shasum -a 256 "${PRODUCT_NAME}-${VERSION}-linux-x86_64.tar.gz" > "${PRODUCT_NAME}-${VERSION}-linux-checksums.txt"
shasum -a 256 "${PRODUCT_NAME}-${VERSION}-linux-aarch64.tar.gz" >> "${PRODUCT_NAME}-${VERSION}-linux-checksums.txt"
