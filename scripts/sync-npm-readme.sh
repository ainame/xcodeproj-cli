#!/bin/bash
set -euo pipefail

# Script to generate npm/README.md with npm-focused content
# Keeps the npm README fresh while maintaining npm-specific messaging

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NPM_README="$PROJECT_ROOT/npm/README.md"

echo "Syncing npm README..."

# Generate npm-focused README with current content
cat > "$NPM_README" << 'EOF'
# xcodeproj CLI

A command-line tool for manipulating Xcode project files (.xcodeproj) using Swift. Perfect for automation, CI/CD pipelines, and AI coding assistants.

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

## Key Features

### 🏗️ Project Creation & Management
- `xcodeproj create` - Create new Xcode projects
- `xcodeproj list-targets` - List all targets
- `xcodeproj list-files` - List files in targets

### 📁 File Management
- `xcodeproj add-file` - Add files to projects
- `xcodeproj remove-file` - Remove files
- `xcodeproj move-file` - Move/rename files
- `xcodeproj create-group` - Create groups

### 🎯 Target Operations
- `xcodeproj add-target` - Create new targets
- `xcodeproj remove-target` - Remove targets
- `xcodeproj duplicate-target` - Duplicate targets
- `xcodeproj add-dependency` - Add dependencies

### ⚙️ Build Configuration
- `xcodeproj set-build-setting` - Modify build settings
- `xcodeproj add-framework` - Add frameworks
- `xcodeproj add-build-phase` - Add build phases

### 📦 Swift Package Management
- `xcodeproj add-swift-package` - Add Swift packages
- `xcodeproj list-swift-packages` - List packages
- `xcodeproj remove-swift-package` - Remove packages

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