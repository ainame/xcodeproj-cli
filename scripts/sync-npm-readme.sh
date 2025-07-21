#!/bin/bash
set -euo pipefail

# Script to sync npm/README.md from main README.md
# Extracts relevant sections and adds npm-specific content

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MAIN_README="$PROJECT_ROOT/README.md"
NPM_README="$PROJECT_ROOT/npm/README.md"

echo "Syncing npm README from main README..."

if [ ! -f "$MAIN_README" ]; then
    echo "Error: Main README.md not found at $MAIN_README"
    exit 1
fi

# Extract the main description (first few lines after title)
DESCRIPTION=$(sed -n '3p' "$MAIN_README")

# Extract the Features section (everything between ## Features and ## Installation)
FEATURES_SECTION=$(awk '/^## Features$/,/^## Installation$/' "$MAIN_README" | sed '$d')

# Generate npm-focused README
cat > "$NPM_README" << EOF
# xcodeproj CLI

$DESCRIPTION Perfect for automation, CI/CD pipelines, and AI coding assistants.

## Quick Start

```bash
# Install globally
npm install -g @ainame/xcodeproj-cli

# Verify installation
xcodeproj --version

# Get help
xcodeproj --help
```

## Platform Support

**Automatically downloads the correct binary for your platform:**

- **macOS**: Intel (x64) and Apple Silicon (arm64)
- **Linux**: x86_64 and aarch64 (ARM64)

Perfect for CI/CD environments, Docker containers, and development machines.

$FEATURES_SECTION

EOF

# Add npm-specific content
cat >> "$NPM_README" << 'EOF'

## Example Usage

```bash
# Create a new iOS app project
xcodeproj create MyApp --bundle-identifier com.mycompany.myapp

# Add a Swift file
xcodeproj add-file MyApp.xcodeproj Sources/ContentView.swift --target MyApp

# Add a Swift package dependency
xcodeproj add-swift-package MyApp.xcodeproj \
  --url https://github.com/apple/swift-algorithms \
  --requirement "exact:1.0.0" \
  --target MyApp

# Set a build setting
xcodeproj set-build-setting MyApp.xcodeproj MyApp \
  --setting SWIFT_VERSION --value 5.9
```

## Why Use xcodeproj CLI?

### 🚀 **Speed & Efficiency**
- CLI tools start instantly without server overhead
- Perfect for automation and scripting

### 🤖 **AI Agent Friendly**
- Simple, explicit commands that AI can easily execute
- Self-contained operations without context dependency

### 🔄 **CI/CD Ready**
- Cross-platform support (macOS and Linux)
- Integrates seamlessly into build pipelines
- No GUI required

### 📋 **Comprehensive**
19 commands covering all common Xcode project operations

## Use Cases

- **Automated project setup** in CI/CD pipelines
- **AI coding assistants** (Claude Code, Cursor, etc.)
- **Cross-platform development** workflows
- **Bulk project modifications** and maintenance
- **Docker containers** and cloud environments

## Links

- 📖 [Full Documentation](https://github.com/ainame/xcodeproj-cli)
- 🐛 [Report Issues](https://github.com/ainame/xcodeproj-cli/issues)
- 🍺 [Homebrew Formula](https://github.com/ainame/xcodeproj-cli#homebrew-macos-only) (macOS only)

---

Built with ❤️ using Swift and [XcodeProj](https://github.com/tuist/xcodeproj)
EOF

echo "✓ npm README synced successfully"
echo "Generated: $NPM_README"