#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <version> <tar.gz-file>"
    echo "Example: $0 0.1.3 build/macos/xcodeproj-0.1.3-macos-universal.tar.gz"
    exit 1
fi

VERSION=$1
TAR_FILE=$2

# Calculate SHA256
SHA256=$(shasum -a 256 "$TAR_FILE" | cut -d' ' -f1)

# Update Formula
sed -i '' "s|url \".*\"|url \"https://github.com/ainame/xcodeproj-cli/releases/download/$VERSION/xcodeproj-$VERSION-macos-universal.tar.gz\"|" Formula/xcodeproj.rb
sed -i '' "s/sha256 \".*\"/sha256 \"$SHA256\"/" Formula/xcodeproj.rb

echo "Updated Formula/xcodeproj.rb:"
echo "  Version: $VERSION"
echo "  SHA256: $SHA256"