# xcodeproj CLI

A command-line tool for manipulating Xcode project files (.xcodeproj) using Swift. This tool provides comprehensive functionality to create, modify, and manage Xcode projects programmatically.

## Overview

xcodeproj CLI is a Swift-based command-line interface that enables developers to automate Xcode project management tasks. It supports all major project operations including file management, target configuration, dependency management, and build settings modification.

## Motivation

This project was inspired by a [YouTube video](https://youtu.be/nfOVgz_omlU?si=WqrwS-kxpN9dUbkb&t=1118) that recommended using fast and user-friendly command-line tools instead of Model Context Protocol (MCP) servers for certain workflows. While MCP servers can take advantage of context and are excellent for interactive use, CLI tools offer distinct advantages:

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

### Quick Install (Recommended)

```bash
# Download and install latest version automatically
curl -sSL https://raw.githubusercontent.com/ainame/xcodeproj_cli/main/install.sh | bash
```

### Manual Download

```bash
# Download latest release
curl -L -o xcodeproj.tar.gz "https://github.com/ainame/xcodeproj_cli/releases/latest/download/xcodeproj-v0.0.1-macos-universal.tar.gz"

# Extract and install
tar -xzf xcodeproj.tar.gz
chmod +x xcodeproj
sudo mv xcodeproj /usr/local/bin/
```

### Homebrew (Coming Soon)

```bash
brew tap ainame/tap
brew install xcodeproj
```

### Build from Source

```bash
git clone https://github.com/ainame/xcodeproj_cli.git
cd xcodeproj_cli
swift build -c release
cp .build/release/xcodeproj /usr/local/bin/
```

### Requirements
- macOS 13.0 or later
- For building from source: Swift 5.7+ and Xcode 14.0+

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

## Architecture

The project is built using:

- **Swift ArgumentParser** for command-line interface structure
- **XcodeProj** library for .xcodeproj file manipulation
- **PathKit** for file system path handling

Each command is implemented as a separate `ParsableCommand` struct, making the codebase modular and extensible.

## Development

### Project Structure

```
xcodeproj_cli/
├── Package.swift
├── Sources/
│   └── xcodeproj_cli/
│       ├── xcodeproj_cli.swift          # Main CLI entry point
│       ├── Utilities/
│       │   └── ErrorHandling.swift     # Error handling utilities
│       └── Commands/                   # Individual command implementations
│           ├── CreateCommand.swift
│           ├── AddFileCommand.swift
│           └── ...
├── Tests/
└── README.md
```

### Adding New Commands

1. Create a new command file in `Sources/xcodeproj_cli/Commands/`
2. Implement the `ParsableCommand` protocol
3. Add the command to the main CLI configuration in `xcodeproj_cli.swift`

### Testing

Run the test suite:

```bash
swift test
```

Build and test manually:

```bash
swift build
.build/debug/xcodeproj --help
```

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

### Guidelines

1. Follow Swift coding conventions
2. Add appropriate error handling
3. Include help documentation for new commands
4. Test your changes thoroughly
5. Update this README for new features

## License

This project is available under the MIT License. See the LICENSE file for more details.

## Acknowledgments

This project builds upon the excellent work of several open-source projects and their contributors:

### Core Dependencies

- **[tuist/XcodeProj](https://github.com/tuist/XcodeProj)** - The foundational library that enables reading, updating, and writing Xcode project files. Created and maintained by the Tuist team, this library provides the core functionality that makes xcodeproj CLI possible.

- **[apple/swift-argument-parser](https://github.com/apple/swift-argument-parser)** - Apple's Swift library for parsing command-line arguments, which provides the robust CLI interface framework used throughout this project.

### Inspiration and Reference

- **[giginet/xcodeproj-mcp-server](https://github.com/giginet/xcodeproj-mcp-server)** - Created by Kohki Miki (@giginet), this Model Context Protocol (MCP) server provided the initial inspiration and reference implementation for many of the commands in this CLI tool. The MCP server's comprehensive feature set and well-structured codebase served as an excellent foundation for porting functionality to a standalone command-line interface.

### Special Thanks

- **Tuist Team** - For creating and maintaining XcodeProj, an essential tool for the iOS development ecosystem
- **Kohki Miki (@giginet)** - For the original MCP server implementation and demonstrating comprehensive Xcode project manipulation capabilities
- **Apple Swift Team** - For Swift ArgumentParser and the Swift programming language
- **The Swift Community** - For continuous contributions to the Swift ecosystem

This project demonstrates the power of building upon existing open-source work to create new tools that serve the developer community.