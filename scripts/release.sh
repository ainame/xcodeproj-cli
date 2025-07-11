#!/bin/bash
set -euo pipefail

# Release script for xcodeproj-cli
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.1.3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if version argument is provided
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Version number required${NC}"
    echo "Usage: $0 <version>"
    echo "Example: $0 0.1.3"
    exit 1
fi

VERSION=$1
TAG="${VERSION}"

# Validate version format (basic check)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
    echo -e "${RED}Error: Invalid version format${NC}"
    echo "Expected format: X.Y.Z or X.Y.Z-suffix"
    echo "Examples: 0.1.3, 1.0.0, 0.2.0-beta"
    exit 1
fi

echo -e "${GREEN}🚀 Starting release process for version ${VERSION}${NC}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: You have uncommitted changes${NC}"
    echo "Please commit or stash your changes before releasing"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}Warning: You're not on the main branch (current: $CURRENT_BRANCH)${NC}"
    read -p "Do you want to continue? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Release cancelled"
        exit 1
    fi
fi

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo -e "${RED}Error: Tag $TAG already exists${NC}"
    exit 1
fi

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Update version in Command.swift
echo "📝 Updating version in Command.swift..."
sed -i '' "s/version: \"[^\"]*\"/version: \"$VERSION\"/" Sources/xcodeproj-cli/Command.swift

# Verify the change
if ! grep -q "version: \"$VERSION\"" Sources/xcodeproj-cli/Command.swift; then
    echo -e "${RED}Error: Failed to update version in Command.swift${NC}"
    exit 1
fi

# Build the project to ensure it compiles
echo "🔨 Building project..."
swift build -c release

# Run tests
echo "🧪 Running tests..."
if [ -f "scripts/test.sh" ]; then
    ./scripts/test.sh
else
    echo -e "${YELLOW}Warning: No test script found, skipping tests${NC}"
fi

# Commit version bump
echo "💾 Committing version bump..."
git add Sources/xcodeproj-cli/Command.swift
git commit -m "chore: bump version to $VERSION

- Update Command.swift version to $VERSION
- Prepare for release

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Create annotated tag
echo "🏷️  Creating tag $TAG..."
git tag -a "$TAG" -m "Release $TAG

Version $VERSION

See CHANGELOG.md for details."

# Push changes and tag
echo "📤 Pushing to remote..."
git push origin main
git push origin "$TAG"

echo -e "${GREEN}✅ Release $VERSION prepared successfully!${NC}"
echo ""
echo "The GitHub Actions workflow will now:"
echo "  1. Build universal binary"
echo "  2. Create GitHub release"
echo "  3. Upload release assets"
echo "  4. Update Homebrew formula"
echo ""
echo "Monitor the release at: https://github.com/ainame/xcodeproj-cli/actions"
echo ""
echo "After the workflow completes, the Homebrew formula will be automatically updated."