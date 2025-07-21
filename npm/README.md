# xcodeproj CLI

A command-line tool for manipulating Xcode project files (.xcodeproj) using Swift. This tool provides comprehensive functionality to create, modify, and manage Xcode projects programmatically. This is especially handy when writing code with coding agent such as Claude Code, Gemini CLI, or Codex. Perfect for automation, CI/CD pipelines, and AI coding assistants.

## Quick Start


added 1 package in 33s
0.2.1
OVERVIEW: A tool for manipulating Xcode project files

USAGE: xcodeproj <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  create                  Create a new Xcode project file (.xcodeproj)
  list-targets            List all targets in an Xcode project
  list-build-configurations
                          List all build configurations in an Xcode project
  list-files              List all files in a specific target of an Xcode
                          project
  get-build-settings      Get build settings for a specific target in an Xcode
                          project
  add-file                Add a file to an Xcode project
  remove-file             Remove a file from the Xcode project
  move-file               Move or rename a file within the project
  create-group            Create a new group in the project navigator
  add-target              Create a new target
  remove-target           Remove an existing target
  add-dependency          Add dependency between targets
  set-build-setting       Modify build settings for a target
  add-framework           Add framework dependencies
  list-swift-packages     List all Swift Package dependencies in an Xcode
                          project
  add-swift-package       Add a Swift Package dependency to an Xcode project
  remove-swift-package    Remove a Swift Package dependency from an Xcode
                          project
  add-build-phase         Add custom build phases
  duplicate-target        Duplicate an existing target

  See 'xcodeproj help <subcommand>' for detailed help.

## Platform Support

**Automatically downloads the correct binary for your platform:**

- **macOS**: Intel (x64) and Apple Silicon (arm64)
- **Linux**: x86_64 and aarch64 (ARM64)

Perfect for CI/CD environments, Docker containers, and development machines.

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
