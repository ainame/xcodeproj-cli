#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.3"
    exit 1
fi

VERSION=$1

# Update version in Command.swift
sed -i '' "s/version: \"[^\"]*\"/version: \"$VERSION\"/" Sources/xcodeproj-cli/Command.swift

# Commit version bump
git add Sources/xcodeproj-cli/Command.swift
git commit -m "chore: bump version to $VERSION"

# Create and push tag
git tag "$VERSION"
git push origin main
git push origin "$VERSION"

echo "Released version $VERSION"