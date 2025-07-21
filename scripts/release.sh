#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.3"
    exit 1
fi

VERSION=$1

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid version format. Use semantic versioning (e.g., 0.1.3)"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Error: Must be on main branch to release (currently on $CURRENT_BRANCH)"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

# Update version in Command.swift
sed -i '' "s/version: \"[^\"]*\"/version: \"$VERSION\"/" Sources/xcodeproj-cli/Command.swift

# Update version in npm package.json
if [ -f npm/package.json ]; then
    # Use a temporary file for compatibility
    TMP_FILE=$(mktemp)
    jq --arg version "$VERSION" '.version = $version' npm/package.json > "$TMP_FILE" && mv "$TMP_FILE" npm/package.json
    echo "Updated npm/package.json version to $VERSION"
fi

# Sync npm README from main README
if [ -f scripts/sync-npm-readme.sh ]; then
    echo "Syncing npm README..."
    ./scripts/sync-npm-readme.sh
fi

# Build and test before committing
echo "Building project..."
swift build -c release
echo "Running tests..."
./scripts/test.sh

# Commit version bump
git add Sources/xcodeproj-cli/Command.swift
if [ -f npm/package.json ]; then
    git add npm/package.json
fi
if [ -f npm/README.md ]; then
    git add npm/README.md
fi
git commit -m "chore: bump version to $VERSION"

# Create and push tag
git tag "$VERSION"
git push origin main
git push origin "$VERSION"

echo "Released version $VERSION"