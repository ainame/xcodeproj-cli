#!/bin/bash
set -euo pipefail

# Script to build npm package for xcodeproj-cli

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NPM_DIR="$PROJECT_ROOT/npm"

echo "Building npm package for xcodeproj-cli..."

# Check if we're in the right directory
if [ ! -f "$PROJECT_ROOT/Package.swift" ]; then
    echo "Error: Package.swift not found. Are you in the xcodeproj-cli directory?"
    exit 1
fi

# Get version from Command.swift
VERSION=$(grep -E 'static let version = "[0-9]+\.[0-9]+\.[0-9]+"' "$PROJECT_ROOT/Sources/xcodeproj-cli/Command.swift" | sed 's/.*"\(.*\)".*/\1/')
if [ -z "$VERSION" ]; then
    echo "Error: Could not extract version from Command.swift"
    exit 1
fi

echo "Version: $VERSION"

# Update package.json version
cd "$NPM_DIR"
if [ -f package.json ]; then
    # Use a temporary file for compatibility
    TMP_FILE=$(mktemp)
    jq --arg version "$VERSION" '.version = $version' package.json > "$TMP_FILE" && mv "$TMP_FILE" package.json
    echo "Updated package.json version to $VERSION"
else
    echo "Error: package.json not found in npm directory"
    exit 1
fi

# Create package
echo "Creating npm package..."
npm pack

echo ""
echo "✓ npm package built successfully"
echo "Package: ainame-xcodeproj-cli-${VERSION}.tgz"
echo ""
echo "To test locally:"
echo "  npm install -g ./ainame-xcodeproj-cli-${VERSION}.tgz"
echo ""
echo "To publish:"
echo "  npm publish ./ainame-xcodeproj-cli-${VERSION}.tgz"