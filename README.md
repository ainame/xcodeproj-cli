# xcodeproj CLI

A command-line tool for manipulating Xcode project files (.xcodeproj) using Swift. This tool provides comprehensive functionality to create, modify, and manage Xcode projects programmatically. This is especially handy when writing code with coding agent such as Claude Code, Gemini CLI, or Codex.

## Motivation

This project was inspired by a [YouTube video](https://youtu.be/nfOVgz_omlU?si=WqrwS-kxpN9dUbkb&t=1118) that recommended using  command-line tools instead of Model Context Protocol (MCP) servers for certain workflows. While MCP servers can take advantage of context and are excellent for interactive use, CLI tools offer distinct advantages:

- **Speed and Efficiency**: CLI tools start instantly without server overhead
- **User-Friendly**: Simple, straightforward command syntax
- **Agent-Friendly**: Perfect for use with AI coding agents that can quickly execute commands
- **No Context Dependency**: Each command is self-contained and explicit
- **Automation-Ready**: Easy to integrate into scripts, CI/CD pipelines, and development workflows

By converting the functionality from an MCP server to a standalone CLI, we get the best of both worlds: the comprehensive Xcode project manipulation capabilities with the speed and simplicity that developers expect from command-line tools.

## Features

### Core Operations
- **create** - Create new Xcode projects with custom configuration
- **list-targets** - List all targets in a project
- **list-build-configurations** - List all build configurations
- **list-files** - List files in specific targets
- **get-build-settings** - Retrieve build settings for targets

### File Management
- **add-file** - Add files to projects and targets
- **remove-file** - Remove files from projects
- **move-file** - Move or rename files within projects
- **create-group** - Create groups in the project navigator

### Target Management
- **add-target** - Create new targets with various product types
- **remove-target** - Remove existing targets
- **duplicate-target** - Duplicate targets with all configurations
- **add-dependency** - Add dependencies between targets

### Build Configuration
- **set-build-setting** - Modify build settings for targets
- **add-framework** - Add system and custom framework dependencies
- **add-build-phase** - Add custom run-script and copy-files build phases

### Swift Package Management
- **list-swift-packages** - List all Swift Package dependencies
- **add-swift-package** - Add Swift Package dependencies with version requirements
- **remove-swift-package** - Remove Swift Package dependencies

## Installation

### npm

Cross-platform installation for any environment:

```bash
npm install -g @ainame/xcodeproj-cli
```

**Supported platforms:**
- **macOS**: Intel (x64) and Apple Silicon (arm64)  
- **Linux**: x86_64 and aarch64 (ARM64)

Perfect for CI/CD pipelines, Docker containers, AI coding assistants, and development machines. The appropriate binary is automatically downloaded during installation.

### Homebrew (macOS only)

```bash
brew tap ainame/xcodeproj-cli https://github.com/ainame/xcodeproj-cli
brew install xcodeproj
```

### Build from Source

<details>

```bash
git clone https://github.com/ainame/xcodeproj-cli.git
cd xcodeproj-cli
swift build -c release

# Option 1: Copy to a directory in your PATH
cp .build/release/xcodeproj /path/to/your/bin/

# Option 2: Add to PATH in your shell profile
echo 'export PATH="$PATH:/path/to/xcodeproj-cli/.build/release"' >> ~/.zshrc
source ~/.zshrc

# Option 3: Create an alias
echo 'alias xcodeproj="/path/to/xcodeproj-cli/.build/release/xcodeproj"' >> ~/.zshrc
source ~/.zshrc
```

</details>

## Usage

### Basic Commands

```bash
# Create a new Xcode project
xcodeproj create MyApp --organization-name "My Company" --bundle-identifier "com.mycompany.myapp"

# List all targets in a project
xcodeproj list-targets MyApp.xcodeproj

# Add a file to a target
xcodeproj add-file MyApp.xcodeproj MyApp Sources/NewFile.swift

# Create a new target
xcodeproj add-target MyApp.xcodeproj MyFramework framework com.mycompany.myframework

# Add a dependency between targets
xcodeproj add-dependency MyApp.xcodeproj MyApp MyFramework

# Add a framework dependency
xcodeproj add-framework MyApp.xcodeproj MyApp UIKit

# Add a Swift Package dependency
xcodeproj add-swift-package MyApp.xcodeproj https://github.com/apple/swift-argument-parser "from: 1.0.0" --target-name MyApp

# Set build settings
xcodeproj set-build-setting MyApp.xcodeproj MyApp SWIFT_VERSION 5.9

# Add a run script build phase
xcodeproj add-build-phase run-script MyApp.xcodeproj MyApp "SwiftLint" "swiftlint"

# Duplicate a target
xcodeproj duplicate-target MyApp.xcodeproj MyApp MyApp-Staging --new-bundle-identifier com.mycompany.myapp.staging
```

### Advanced Usage

#### Swift Package Version Requirements

The tool supports various Swift Package version requirement formats:

```bash
# Exact version
xcodeproj add-swift-package MyApp.xcodeproj https://github.com/realm/realm-swift "10.45.0"

# From version (up to next major)
xcodeproj add-swift-package MyApp.xcodeproj https://github.com/realm/realm-swift "from: 10.0.0"

# Up to next minor version
xcodeproj add-swift-package MyApp.xcodeproj https://github.com/realm/realm-swift "upToNextMinor: 10.45.0"

# Branch reference
xcodeproj add-swift-package MyApp.xcodeproj https://github.com/realm/realm-swift "branch: main"

# Specific revision
xcodeproj add-swift-package MyApp.xcodeproj https://github.com/realm/realm-swift "revision: abc123"
```

#### Build Phase Management

Add custom build phases with various types:

```bash
# Run script build phase
xcodeproj add-build-phase run-script MyApp.xcodeproj MyApp "Code Generation" "scripts/generate_code.sh"

# Copy files build phase
xcodeproj add-build-phase copy-files MyApp.xcodeproj MyApp "Copy Resources" resources --files config.plist assets.bundle
```

### Getting Help

```bash
# General help
xcodeproj --help

# Command-specific help
xcodeproj create --help
xcodeproj add-swift-package --help
```

## Development

### Testing

#### macOS Testing
Run local macOS tests:
```bash
scripts/test.sh
```

#### Linux Compatibility Testing

**On Linux (CI/CD or native Linux development):**
```bash
scripts/test-linux-native.sh
```

**On macOS/Windows (local development with Docker):**
```bash
scripts/test-linux.sh
```

#### Comprehensive Testing
Run all tests (macOS + Linux) with automatic environment detection:
```bash
# Run all tests (automatically chooses native or Docker-based Linux tests)
scripts/test-all.sh

# Skip Linux tests if needed
scripts/test-all.sh --skip-linux
```

**Prerequisites for Linux Testing:**
- **Native Linux**: Node.js and npm installed
- **Docker-based**: Docker installed and running
- Network access for npm package installation

The Linux tests verify full compatibility by:
- Installing the published npm package (natively on Linux, or in Docker container)
- Testing all 19 CLI commands with real Xcode project manipulation
- Validating Swift Package Manager integration
- Ensuring proper error handling and output formatting

**Environment-aware testing:**
- On Linux: Uses native testing (no Docker overhead)
- On macOS/Windows: Uses Docker-based testing
- GitHub Actions: Uses efficient native Linux testing

### Release Process

To release a new version:

```bash
# Release with full testing (macOS + Linux)
scripts/release.sh 0.1.4

# Release without Linux tests (if Docker unavailable)
scripts/release.sh 0.1.4 --skip-linux
```

The release script automatically:
1. Validates version format and git state
2. Updates version in `Command.swift` and `package.json`
3. Builds the project in release mode
4. Runs macOS tests (`scripts/test.sh`)
5. Runs Linux compatibility tests (environment-aware: native on Linux, Docker on macOS) - unless skipped
6. Commits version changes
7. Creates and pushes git tag
8. Triggers GitHub Actions for binary builds, npm publishing, and post-publish Linux testing

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Requirements

- Swift 6.1+ and Xcode 16.4+ (for building from source)
- Universal binary supports both Apple Silicon and Intel Macs

## License

This project is available under the MIT License. See the LICENSE file for more details.

## Acknowledgments

This project builds upon the excellent work of these open-source projects and their contributors:

- **[giginet/xcodeproj-mcp-server](https://github.com/giginet/xcodeproj-mcp-server)** - Created by @giginet, this Model Context Protocol (MCP) server provided the initial inspiration and reference implementation for many of the commands in this CLI tool. The MCP server's comprehensive feature set and well-structured codebase served as an excellent foundation for porting functionality to a standalone command-line interface.
- **[tuist/XcodeProj](https://github.com/tuist/XcodeProj)** - The foundational library that enables reading, updating, and writing Xcode project files. Created and maintained by the Tuist team, this library provides the core functionality that makes xcodeproj CLI possible.
