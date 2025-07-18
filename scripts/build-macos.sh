#!/bin/bash
set -euo pipefail

PRODUCT_NAME="xcodeproj"
BUILD_DIR="build/macos"

# Get version from Command.swift
VERSION=$(grep 'version:' Sources/xcodeproj-cli/Command.swift | sed 's/.*version: "\(.*\)".*/\1/')

echo "Building macOS universal binary for version $VERSION"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/arm64" "$BUILD_DIR/x86_64" "$BUILD_DIR/universal"

# Build for arm64
echo "Building for arm64..."
swift build -c release --arch arm64
cp ".build/arm64-apple-macosx/release/$PRODUCT_NAME" "$BUILD_DIR/arm64/"

# Build for x86_64
echo "Building for x86_64..."
swift build -c release --arch x86_64
cp ".build/x86_64-apple-macosx/release/$PRODUCT_NAME" "$BUILD_DIR/x86_64/"

# Create universal binary
echo "Creating universal binary..."
lipo -create -output "$BUILD_DIR/universal/$PRODUCT_NAME" \
    "$BUILD_DIR/arm64/$PRODUCT_NAME" \
    "$BUILD_DIR/x86_64/$PRODUCT_NAME"

# Create archive
cd "$BUILD_DIR/universal"
tar -czf "../$PRODUCT_NAME-$VERSION-macos-universal.tar.gz" "$PRODUCT_NAME"
cd -

# Generate checksums
cd "$BUILD_DIR"
shasum -a 256 "$PRODUCT_NAME-$VERSION-macos-universal.tar.gz" > "$PRODUCT_NAME-$VERSION-macos-checksums.txt"
cd -

echo "Build complete: $BUILD_DIR/$PRODUCT_NAME-$VERSION-macos-universal.tar.gz"